local Queue = require "queue"
local map = {}
local modifiedMap = {}
quadsize = 23;
width = 20
height = 25

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
    print(diffs)
end

function love.load()
    love.window.setMode(1024, 768)
    love.window.setTitle("Pathfind 2017")
    math.randomseed( os.time() )
    generateMaze()
end

function drawMaze(maze, offset)  
    love.graphics.setColor(255, 255, 255)
    for i = 1, height do
        for j = 1, width do
            if maze[i][j] > 0 then
                love.graphics.rectangle("fill", offset + j*quadsize, i*quadsize, quadsize, quadsize)
            end
        end
    end  
end

function drawMapLines(offset)
    love.graphics.setColor(0,0,0) 
    for i = 1, height do
        for j = 1, width do
            if bit.band(map[i][j], 1) == 0 then
                love.graphics.line(offset+j*quadsize, i*quadsize, offset+(j+1)*quadsize, i*quadsize)
            end
            if bit.band(map[i][j], 2) == 0 then
                love.graphics.line(offset+(j+1)*quadsize, i*quadsize, offset+(j+1)*quadsize, (i+1)*quadsize)
            end
            if bit.band(map[i][j], 4) == 0 then
                love.graphics.line(offset+j*quadsize, (i+1)*quadsize, offset+(j+1)*quadsize, (i+1)*quadsize)
            end
            if bit.band(map[i][j], 8) == 0 then
                love.graphics.line(offset+j*quadsize, i*quadsize, offset+j*quadsize, (i+1)*quadsize)
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

function love.draw()
    love.graphics.clear()
    love.graphics.setLineWidth(2)
    drawMaze(map, 0) 
    drawMapLines(0)
    drawMaze(modifiedMap, width*quadsize + 50)
    drawModifiedMapLines(width*quadsize + 50)
end

function love.update(dt)

end