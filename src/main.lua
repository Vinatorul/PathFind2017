local Queue = require "queue"
local map = {}
local modifiedMap = {}
local posibilitiesMap = {}
local robotX = 0
local prevRobotX = 0
local robotY = 0
local prevRobotY = 0
local destX = 0
local destY = 0
local mapPath = {}
local posibilitiesMapPath = {}
local modifiedMapPath = {}
local botMaze = {}
local possiblePositions = {}
local visited = {}
local start = false
quadsize = 23;
width = 20
height = 15

function generateMaze()
    for i = 1, height do
        map[i] = {}
        botMaze[i] = {}
        visited[i] = {}
        possiblePositions[i] = {}
        for j = 1, width do
            map[i][j] = 0
            botMaze[i][j] = 0
            visited[i][j] = 0
            possiblePositions[i][j] = 0
        end
    end
    q = Queue.new()
    for i = 1, height do
        for j = 1, width do
            if map[i][j] == 0 then
                Queue.push(q, {j, i}) 
                while (not Queue.empty(q)) do
                    tmp = Queue.pop(q)
                    x = tmp[1]
                    y = tmp[2]
                    if (y > 1) and (math.random(3) == 1) and bit.band(map[y][x], 1) == 0 then
                        Queue.push(q, {x, y-1})   
                        map[y][x] = map[y][x] + 1
                        map[y-1][x] = map[y-1][x] + 4
                    end
                    if (x < width) and (math.random(3) == 1) and bit.band(map[y][x], 2) == 0 then
                        Queue.push(q, {x+1, y})   
                        map[y][x] = map[y][x] + 2
                        map[y][x+1] = map[y][x+1] + 8
                    end
                    if (y < height) and (math.random(3) == 1) and bit.band(map[y][x], 4) == 0 then
                            Queue.push(q, {x, y+1})   
                        map[y][x] = map[y][x] + 4
                        map[y+1][x] = map[y+1][x] + 1
                    end
                    if (x > 1) and (math.random(3) == 1) and bit.band(map[y][x], 8) == 0 then
                        Queue.push(q, {x-1, y})   
                        map[y][x] = map[y][x] + 8
                        map[y][x-1] = map[y][x-1] + 2
                    end
                end
            end
        end
    end 
    for i = 1, height do
        modifiedMap[i] = {}
        for j = 1, width do
            modifiedMap[i][j] = map[i][j]
        end
    end
    diffs = 0
    for i = 2, height-1 do
        for j = 2, width-1 do
            rand = math.random(30)
            if (rand == 1) then
                diffs = diffs + 1
                if bit.band(modifiedMap[i][j], 1) == 0 then
                    modifiedMap[i][j] = modifiedMap[i][j] + 1
                    modifiedMap[i-1][j] = modifiedMap[i-1][j] + 4
                else                
                    modifiedMap[i][j] = modifiedMap[i][j] - 1
                    modifiedMap[i-1][j] = modifiedMap[i-1][j] - 4
                end
            end
            if (rand == 2) then
                diffs = diffs + 1
                if bit.band(modifiedMap[i][j], 2) == 0 then
                    modifiedMap[i][j] = modifiedMap[i][j] + 2
                    modifiedMap[i][j+1] = modifiedMap[i][j+1] + 8
                else                  
                    modifiedMap[i][j] = modifiedMap[i][j] - 2
                    modifiedMap[i][j+1] = modifiedMap[i][j+1] - 8
                end
            end
            if (rand == 4) then
                diffs = diffs + 1
                if bit.band(modifiedMap[i][j], 4) == 0 then
                    modifiedMap[i][j] = modifiedMap[i][j] + 4
                    modifiedMap[i+1][j] = modifiedMap[i+1][j] + 1
                else                  
                    modifiedMap[i][j] = modifiedMap[i][j] - 4
                    modifiedMap[i+1][j] = modifiedMap[i+1][j] - 1
                end
            end
            if (rand == 8) then
                diffs = diffs + 1
                if bit.band(modifiedMap[i][j], 8) == 0 then
                    modifiedMap[i][j] = modifiedMap[i][j] + 8
                    modifiedMap[i][j-1] = modifiedMap[i][j-1] + 2
                else                  
                    modifiedMap[i][j] = modifiedMap[i][j] - 8
                    modifiedMap[i][j-1] = modifiedMap[i][j-1] - 2
                end
            end
        end
    end
    for i = 1, height do
        posibilitiesMap[i] = {}
        for j = 1, width do
            posibilitiesMap[i][j] = map[i][j]
        end
    end
    print(diffs)
end

function love.load()
    love.window.setMode(1024, 768)
    love.window.setTitle("Pathfind 2017")
    math.randomseed( os.time() )
    flag = false
    while (not flag) do
        generateMaze()
        flag = setPositions()
    end
    mapPath = calcPath(map)
    modifiedMapPath = calcPath(modifiedMap)
    posibilitiesMapPath = calcPath(posibilitiesMap)
    love.keypressed = procKeyboard
    updateBot()
end

function drawMaze(maze, offset_x, offset_y)
    love.graphics.setColor(255, 255, 255)
    for i = 1, height do
        for j = 1, width do
            if maze[i][j] > 0 then
                love.graphics.rectangle("fill", offset_x + j*quadsize, i*quadsize + offset_y, quadsize, quadsize)
            end
        end
    end  
end

function drawMapLines(maze, offset_x, offset_y)
    love.graphics.setColor(0,0,0) 
    for i = 1, height do
        for j = 1, width do
            if bit.band(maze[i][j], 1) == 0 then
                love.graphics.line(offset_x+j*quadsize, offset_y+i*quadsize, offset_x+(j+1)*quadsize, offset_y+i*quadsize)
            end
            if bit.band(maze[i][j], 2) == 0 then
                love.graphics.line(offset_x+(j+1)*quadsize, offset_y+i*quadsize, offset_x+(j+1)*quadsize, offset_y+(i+1)*quadsize)
            end
            if bit.band(maze[i][j], 4) == 0 then
                love.graphics.line(offset_x+j*quadsize, offset_y+(i+1)*quadsize, offset_x+(j+1)*quadsize, offset_y+(i+1)*quadsize)
            end
            if bit.band(maze[i][j], 8) == 0 then
                love.graphics.line(offset_x+j*quadsize, offset_y+i*quadsize, offset_x+j*quadsize, offset_y+(i+1)*quadsize)
            end
        end
    end 
end

function setLineColor(maze, i, j, b)
    if (bit.band(maze[i][j], b) == 0) and (bit.band(map[i][j], b) == 0) then
        love.graphics.setColor(0, 0, 0)
    else 
        if bit.band(maze[i][j], b) == 0 then
            love.graphics.setColor(255, 0, 0)
        else
            love.graphics.setColor(0, 255, 0)
        end
    end
end

function drawModifiedMapLines(maze, offset_x, offset_y)
    for i = 1, height do
        for j = 1, width do
            if (bit.band(maze[i][j], 1) == 0) or (bit.band(map[i][j], 1) == 0) then
                setLineColor(maze, i, j, 1)
                love.graphics.line(offset_x+j*quadsize, offset_y+i*quadsize, offset_x+(j+1)*quadsize, offset_y+i*quadsize)
            end
            if (bit.band(maze[i][j], 2) == 0) or (bit.band(map[i][j], 2) == 0) then
                setLineColor(maze, i, j, 2)
                love.graphics.line(offset_x+(j+1)*quadsize, offset_y+i*quadsize, offset_x+(j+1)*quadsize, offset_y+(i+1)*quadsize)
            end
            if (bit.band(maze[i][j], 4) == 0) or (bit.band(map[i][j], 4) == 0) then
                setLineColor(maze, i, j, 4)
                love.graphics.line(offset_x+j*quadsize, offset_y+(i+1)*quadsize, offset_x+(j+1)*quadsize, offset_y+(i+1)*quadsize)
            end
            if (bit.band(maze[i][j], 8) == 0) or (bit.band(map[i][j], 8) == 0) then
                setLineColor(maze, i, j, 8)
                love.graphics.line(offset_x+j*quadsize, offset_y+i*quadsize, offset_x+j*quadsize, offset_y+(i+1)*quadsize)
            end
        end
    end 
end

function checkPath(maze)
    q = Queue.new()
    used = {}  
    for i = 1, height do
        used[i] = {}
        for j = 1, width do
            used[i][j] = 0
        end
    end
    used[robotY][robotX] = 1
    Queue.push(q, {robotX, robotY})
    while (not Queue.empty(q)) do
        tmp = Queue.pop(q)
        x = tmp[1]
        y = tmp[2]
        if (tmp[1] == destX) and (tmp[2] == destY) then
            return true
        end
        if (y > 1) and bit.band(maze[y][x], 1) ~= 0 and (used[y-1][x] == 0) then
            Queue.push(q, {x, y-1})
            used[y-1][x] = used[y][x]+1
        end
        if (x < width) and bit.band(maze[y][x], 2) ~= 0 and (used[y][x+1] == 0) then
            Queue.push(q, {x+1, y})
            used[y][x+1] = used[y][x]+1
        end
        if (y < height) and bit.band(maze[y][x], 4) ~= 0 and (used[y+1][x] == 0) then
            Queue.push(q, {x, y+1})
            used[y+1][x] = used[y][x]+1
        end
        if (x > 1) and bit.band(maze[y][x], 8) ~= 0 and (used[y][x-1] == 0) then
            Queue.push(q, {x-1, y})
            used[y][x-1] = used[y][x]+1
        end
    end
    print("fail")
    return false
end

function setPositions()
    found = false
    iter = 0
    while (not found) do
        part = math.random(2)
        if (part == 2) then
            part = 4
        end
        part2 = math.random(2) 
        if (part2 == 2) then
            part2 = 4
        end
        w4 = math.floor(width/4)
        h4 = math.floor(height/4)
        robotX = math.random((part-1)*w4 + 1, part*w4)
        robotY = math.random((part2-1)*h4 + 1, part2*h4)
        if (part == 4) then 
            part = 1 
        else 
            part = 4 
        end
        if (part2 == 4) then 
            part2 = 1 
        else 
            part2 = 4 
        end
        destX = math.random((part-1)*w4 + 1, part*w4)
        destY = math.random((part2-1)*h4 + 1, part2*h4)
        print(robotX, robotY, destX, destY)
        found = checkPath(map) and checkPath(modifiedMap)
        iter = iter + 1
        if (iter > 100) then
            print("bad seed")
            return false
        end
    end
    print("alive")
    return true
end

function drawPath(pathArr, offset_x, offset_y) 
    love.graphics.setColor(0, 0, 255)
    for i = 1, height do
        for j = 1, width do
            if pathArr[i][j] > 0 then
                love.graphics.rectangle("fill", offset_x + j*quadsize, i*quadsize + offset_y, quadsize, quadsize)
            end
        end
    end   
end

function drawRobot(offset_x, offset_y)
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle("fill", offset_x + robotX*quadsize, robotY*quadsize + offset_y, quadsize, quadsize)  
end

function drawTarget(offset_x, offset_y)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", offset_x + destX*quadsize, destY*quadsize + offset_y, quadsize, quadsize)  
end

function drawBotMaze(offset_x, offset_y)
    min_x = width
    min_y = height
    for i = 1, height do
        for j = 1, width do
            if botMaze[i][j] ~= 0 then
                min_x = math.min(min_x, j)
                min_y = math.min(min_y, i)
            end
        end
    end
    offset_x = offset_x - (min_x-1)*quadsize
    offset_y = offset_y - (min_y-1)*quadsize
    drawMaze(botMaze, offset_x, offset_y)
    drawMapLines(botMaze, offset_x, offset_y)
    drawRobot(offset_x, offset_y)
end

function drawPossiblePositions(offset_x, offset_y)
    mx = 0
    for i = 1, height do
        for j = 1, width do
            mx = math.max(mx, possiblePositions[i][j]) 
        end
    end
    for i = 1, height do
        for j = 1, width do
            if possiblePositions[i][j] >= 2*mx/3 then
                love.graphics.setColor(70, 255, 70)
                love.graphics.rectangle("fill", offset_x + j*quadsize, 
                    i*quadsize + offset_y, quadsize, quadsize) 
            end
        end
    end
end

function love.draw()
    love.graphics.clear()
    love.graphics.setLineWidth(2)
    if start then
        drawBotMaze(width*quadsize + 50, height*quadsize + 25)
    end

    drawMaze(map, 0, 0) 
    if start then
        drawPath(mapPath, 0, 0)
    end
    drawMapLines(map, 0, 0)
    if start then
        drawRobot(0, 0)
        drawTarget(0, 0)
    end

    drawMaze(modifiedMap, width*quadsize + 50, 0)  
    if start then
        drawPath(modifiedMapPath, width*quadsize + 50, 0)
    end
    drawModifiedMapLines(modifiedMap, width*quadsize + 50, 0)    
    if start then
        drawRobot(width*quadsize + 50, 0)
        drawTarget(width*quadsize + 50, 0)
        drawMaze(posibilitiesMap, 0, height*quadsize + 25) 
        drawModifiedMapLines(posibilitiesMap, 0, height*quadsize + 25)  
        drawPossiblePositions(0, height*quadsize + 25)
        drawTarget(0, height*quadsize + 25)
    end
end

function calcPath(maze)
    q = Queue.new()
    used = {}
    pathArr = {}
    for i = 1, height do
        used[i] = {}
        pathArr[i] = {}
        for j = 1, width do
            used[i][j] = 0
            pathArr[i][j] = 0
        end
    end
    used[robotY][robotX] = 1
    Queue.push(q, {robotX, robotY})
    while (not Queue.empty(q)) do
        tmp = Queue.pop(q)
        x = tmp[1]
        y = tmp[2]
        if (x == destX) and (y == destY) then
            break
        end
        if (y > 1) and bit.band(maze[y][x], 1) ~= 0 and (used[y-1][x] == 0) then
            Queue.push(q, {x, y-1})
            used[y-1][x] = used[y][x]+1
        end
        if (x < width) and bit.band(maze[y][x], 2) ~= 0 and (used[y][x+1] == 0) then
            Queue.push(q, {x+1, y})
            used[y][x+1] = used[y][x]+1
        end
        if (y < height) and bit.band(maze[y][x], 4) ~= 0 and (used[y+1][x] == 0) then
            Queue.push(q, {x, y+1})
            used[y+1][x] = used[y][x]+1
        end
        if (x > 1) and bit.band(maze[y][x], 8) ~= 0 and (used[y][x-1] == 0) then
            Queue.push(q, {x-1, y})
            used[y][x-1] = used[y][x]+1
        end
    end
    if (used[destY][destX] ~= 0) then    
        tX = destX
        tY = destY
        pathArr[tY][tX] = 1
        iter = 1
        while (tX ~= robotX) or (tY ~= robotY) do
            if (tY > 1) and bit.band(maze[tY][tX], 1) ~= 0 and (used[tY-1][tX] ~= 0) and (used[tY-1][tX] < used[tY][tX]) then
                tY = tY-1
                pathArr[tY][tX] = 1
            end
            if (tX < width) and bit.band(maze[tY][tX], 2) ~= 0 and (used[tY][tX+1] ~= 0) and (used[tY][tX+1] < used[tY][tX]) then
                tX = tX+1
                pathArr[tY][tX] = 1
            end
            if (tY < height) and bit.band(maze[tY][tX], 4) ~= 0 and (used[tY+1][tX] ~= 0) and (used[tY+1][tX] < used[tY][tX]) then
                tY = tY+1
                pathArr[tY][tX] = 1
            end
            if (tX > 1) and bit.band(maze[tY][tX], 8) ~= 0 and (used[tY][tX-1] ~= 0) and (used[tY][tX-1] < used[tY][tX]) then
                tX = tX-1
                pathArr[tY][tX] = 1
            end
            iter = iter + 1
            if (iter > 100) then
                print(tX, tY, robotX, robotY, used[tY][tX])
                break
            end
        end
    end
    return pathArr
end

function moveBot()
    if (robotX == destX) and (robotY == destY) then
        return
    end
    mx = 0
    for i = 1, height do
        for j = 1, width do
            mx = math.max(mx, possiblePositions[i][j]) 
        end
    end
    top = 0
    left = 0
    right = 0
    down = 0
    ctMx = 0
    for i = 1, height do
        for j = 1, width do
            if possiblePositions[i][j] >= 2*mx/3 then
                ctMx = ctMx + 1
                if bit.band(map[i][j], 1) ~= 0 then
                    top = top + 1
                end
                if bit.band(map[i][j], 2) ~= 0 then
                    right = right + 1
                end
                if bit.band(map[i][j], 4) ~= 0 then
                    down = down + 1
                end
                if bit.band(map[i][j], 8) ~= 0 then
                    left = left + 1
                end
            end
        end
    end
    if bit.band(modifiedMap[robotY][robotX], 1) == 0 then
        top = 0
        if (ctMx == 1) and (robotY > 1)and (bit.band(posibilitiesMap[robotY][robotX], 1) ~= 0) then 
            posibilitiesMap[robotY][robotX] = posibilitiesMap[robotY][robotX] - 1
            posibilitiesMap[robotY-1][robotX] = posibilitiesMap[robotY-1][robotX] - 4
        end
    else
        if (ctMx == 1) and (posibilitiesMapPath[robotY-1][robotX] ~= 0) then
            top = top + 5
        end
    end
    if bit.band(modifiedMap[robotY][robotX], 2) == 0 then
        right = 0
        if (ctMx == 1) and (robotX < width)and (bit.band(posibilitiesMap[robotY][robotX], 2) ~= 0) then 
            posibilitiesMap[robotY][robotX] = posibilitiesMap[robotY][robotX] - 2
            posibilitiesMap[robotY][robotX+1] = posibilitiesMap[robotY][robotX+1] - 8
        end
    else
        if (ctMx == 1) and (posibilitiesMapPath[robotY][robotX+1] ~= 0) then
            right = right + 5
        end
    end
    if bit.band(modifiedMap[robotY][robotX], 4) == 0 then
        down = 0
        if (ctMx == 1) and (robotY < height)and (bit.band(posibilitiesMap[robotY][robotX], 4) ~= 0) then 
            posibilitiesMap[robotY][robotX] = posibilitiesMap[robotY][robotX] - 4
            posibilitiesMap[robotY+1][robotX] = posibilitiesMap[robotY+1][robotX] - 1
        end
    else
        if (ctMx == 1) and (posibilitiesMapPath[robotY+1][robotX] ~= 0) then
            down = down + 5
        end
    end  
    if bit.band(modifiedMap[robotY][robotX], 8) == 0 then
        left = 0
        if (ctMx == 1) and (robotX > 1) and (bit.band(posibilitiesMap[robotY][robotX], 8) ~= 0) then 
            posibilitiesMap[robotY][robotX] = posibilitiesMap[robotY][robotX] - 8
            posibilitiesMap[robotY][robotX-1] = posibilitiesMap[robotY][robotX-1] - 2
        end
    else
        if (ctMx == 1) and (posibilitiesMapPath[robotY][robotX-1] ~= 0) then
            left = left + 5
        end
    end
    tX = robotX
    tY = robotY
    if (ctMx > 1) then
        w = {top, right, down, left}
        t = math.random(1, 4);
        while (w[t] == 0) do
            t = math.random(1, 4);
        end
        if (t == 1) then
            tY = tY - 1
        end
        if (t == 2) then
            tX = tX + 1
        end
        if (t == 3) then
            tY = tY + 1
        end
        if (t == 4) then
            tX = tX - 1
        end
    else
        mx = math.max(top, left, down, right)
        if (mx == top) then
            tY = tY - 1
            mx = 999
        end
        if (mx == right) then
            tX = tX + 1
            mx = 999
        end
        if (mx == down) then
            tY = tY + 1
            mx = 999
        end
        if (mx == left) then
            tX = tX - 1
            mx = 999
        end
    end
    prevRobotY = robotY
    prevRobotX = robotX
    robotX = tX
    robotY = tY
end

function updateBot()
    visited[robotY][robotX] = 1
    if (robotY > 1) and bit.band(modifiedMap[robotY][robotX], 1) ~= 0 and bit.band(botMaze[robotY][robotX], 1) == 0 then   
        botMaze[robotY][robotX] = botMaze[robotY][robotX] + 1
        botMaze[robotY-1][robotX] = botMaze[robotY-1][robotX] + 4
    end
    if (robotX < width) and bit.band(modifiedMap[robotY][robotX], 2) ~= 0 and bit.band(botMaze[robotY][robotX], 2) == 0 then
        Queue.push(q, {robotX+1, robotY})   
        botMaze[robotY][robotX] = botMaze[robotY][robotX] + 2
        botMaze[robotY][robotX+1] = botMaze[robotY][robotX+1] + 8
    end
    if (robotY < height) and bit.band(modifiedMap[robotY][robotX], 4) ~= 0 and bit.band(botMaze[robotY][robotX], 4) == 0 then
            Queue.push(q, {robotX, robotY+1})   
        botMaze[robotY][robotX] = botMaze[robotY][robotX] + 4
        botMaze[robotY+1][robotX] = botMaze[robotY+1][robotX] + 1
    end
    if (robotX > 1) and bit.band(modifiedMap[robotY][robotX], 8) ~= 0  and bit.band(botMaze[robotY][robotX], 8) == 0 then
        Queue.push(q, {robotX-1, robotY})   
        botMaze[robotY][robotX] = botMaze[robotY][robotX] + 8
        botMaze[robotY][robotX-1] = botMaze[robotY][robotX-1] + 2
    end
end

function procKeyboard(key, scancode, isrepeat)
    processed = false
    if (key == "right") then
        if (robotX < width) then
            robotX = robotX + 1
        end
        processed = true
    end
    if (key == "left") then
        if (robotX > 1) then
            robotX = robotX - 1
        end
        processed = true
    end
    if (key == "up") then
        if (robotY > 1) then
            robotY = robotY - 1
        end
        processed = true
    end
    if (key == "down") then
        if (robotY < height) then
            robotY = robotY + 1
        end
        processed = true
    end
    if (key == "return") then
        start = true
        processed = true
    end
    if (key == "esc") then
        love.window.close()
    end
    if (not processed) then
        print(key, scancode, isrepeat)
    end
end

function checkPos(y, x)
    min_x = width
    min_y = height
    max_x = 1
    max_y = 1
    for i = 1, height do
        for j = 1, width do
            if botMaze[i][j] ~= 0 then
                min_x = math.min(min_x, j)
                min_y = math.min(min_y, i)
                max_x = math.max(max_x, j)
                max_y = math.max(max_y, i)
            end
        end
    end
    if (x <= robotX - min_x) or (y <= robotY - min_y) then
        return 0
    end
    if (x >  width - (max_x - robotX)) or (y > height -(max_y - robotY)) then
        return 0
    end
    off_x = x - robotX
    off_y = y - robotY
    ret = 0
    for j = min_x, max_x do
        for i = min_y, max_y do 
            if (visited[i][j] ~= 0) and (botMaze[i][j] == map[i+off_y][j+off_x]) then
                ret = ret + 1
            end
        end
    end
    return ret
end

function checkPositions()
    for i = 1, height do
        for j = 1, width do
            possiblePositions[i][j] = checkPos(i, j)
        end
    end
end

function love.update(dt)
    if start then
        moveBot()
        updateBot()
        checkPositions()
        mapPath = calcPath(map)
        modifiedMapPath = calcPath(modifiedMap)
        posibilitiesMapPath = calcPath(posibilitiesMap)
        love.timer.sleep(0.5)
    end
end