local Queue = require "queue"
local map = {}
local modifiedMap = {}
local posibilitiesMap = {}
local robotX = 0
local robotY = 0
local destX = 0
local destY = 0
local mapPath = {}
local modifiedMapPath = {}
quadsize = 23;
width = 20
height = 15

function generateMaze()
    for i = 1, height do
        map[i] = {}
        for j = 1, width do
            map[i][j] = 0
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
            rand = math.random(40)
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
    posibilitiesMap = map
    print(diffs)
end

function love.load()
    love.window.setMode(1024, 768)
    love.window.setTitle("Pathfind 2017")
    math.randomseed( os.time() )
    generateMaze()
    setPositions()
    mapPath = calcPath(map)
    modifiedMapPath = calcPath(modifiedMap)
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

function setLineColor(i, j, b)
    if (bit.band(modifiedMap[i][j], b) == 0) and (bit.band(map[i][j], b) == 0) then
        love.graphics.setColor(0, 0, 0)
    else 
        if bit.band(modifiedMap[i][j], b) == 0 then
            love.graphics.setColor(255, 0, 0)
        else
            love.graphics.setColor(0, 255, 0)
        end
    end
end

function drawModifiedMapLines(offset)
    for i = 1, height do
        for j = 1, width do
            if (bit.band(modifiedMap[i][j], 1) == 0) or (bit.band(map[i][j], 1) == 0) then
                setLineColor(i, j, 1)
                love.graphics.line(offset+j*quadsize, i*quadsize, offset+(j+1)*quadsize, i*quadsize)
            end
            if (bit.band(modifiedMap[i][j], 2) == 0) or (bit.band(map[i][j], 2) == 0) then
                setLineColor(i, j, 2)
                love.graphics.line(offset+(j+1)*quadsize, i*quadsize, offset+(j+1)*quadsize, (i+1)*quadsize)
            end
            if (bit.band(modifiedMap[i][j], 4) == 0) or (bit.band(map[i][j], 4) == 0) then
                setLineColor(i, j, 4)
                love.graphics.line(offset+j*quadsize, (i+1)*quadsize, offset+(j+1)*quadsize, (i+1)*quadsize)
            end
            if (bit.band(modifiedMap[i][j], 8) == 0) or (bit.band(map[i][j], 8) == 0) then
                setLineColor(i, j, 8)
                love.graphics.line(offset+j*quadsize, i*quadsize, offset+j*quadsize, (i+1)*quadsize)
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
    end
    print("alive")
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

function love.draw()
    love.graphics.clear()
    love.graphics.setLineWidth(2)
    drawMaze(map, 0, 0) 
    drawPath(mapPath, 0, 0)
    drawMapLines(map, 0, 0)
    drawRobot(0, 0)
    drawTarget(0, 0)

    drawMaze(modifiedMap, width*quadsize + 50, 0)  
    drawPath(modifiedMapPath, width*quadsize + 50, 0)
    drawModifiedMapLines(width*quadsize + 50)    
    drawRobot(width*quadsize + 50, 0)
    drawTarget(width*quadsize + 50, 0)

    drawMaze(posibilitiesMap, 0, height*quadsize + 25) 
    drawMapLines(posibilitiesMap, 0, height*quadsize + 25)  
    drawRobot(0, height*quadsize + 25)
    drawTarget(0, height*quadsize + 25)
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
            if (iter > 1000) then
                print(tX, tY, robotX, robotY, used[tY][tX])
                break
            end
        end
    end
    return pathArr
end

function love.update(dt)
    mapPath = calcPath(map)
    modifiedMapPath = calcPath(modifiedMap)
end