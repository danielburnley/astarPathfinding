function reset()
	nextNode = startNode
	openList = {}
	closedList = {}
	table.insert(closedList, startNode)
	startAdj = checkWalkable(getAdjacent(startNode.x, startNode.y, startNode))
	addToOpenList(startAdj)
	time = 0
	complete = false
	status = "Seaching"
end

function setStartPoint(newX, newY)
	startNode = { x = newX, y = newY, g = 0}
	reset()
end

function setEndPoint(newX, newY)
	endNode = { x = newX, y = newY, g = 0}
	reset()
end


function drawMap()
	for i, row in ipairs(map) do
		for j, col in ipairs(row) do
			if col == 1 then 
				local x = 32 * j
				local y = 32 * i
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle("fill", x, y, 32, 32)
			end
			if col == 0 then
				local x = 32 * j
				local y = 32 * i
				love.graphics.setColor(0, 255, 0, 125)
				love.graphics.rectangle("line", x, y, 32, 32)
			end
		end
	end
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", startNode.x * 32, startNode.y * 32, 32, 32)
	love.graphics.setColor(255, 127, 0)
	love.graphics.rectangle("fill", endNode.x * 32, endNode.y * 32, 32, 32)
end


function getAdjacent(x, y, parent)
	local adj = {}
	if map[y-1][x] == 0 then
		if map[y][x-1] == 0 then 
			adj.topLeft = { x = x - 1, y = y - 1, g = 14 + parent.g, parent = parent}
		end
		if map[y][x+1] == 0 then 
			adj.topRight = { x = x + 1, y = y - 1, g = 14 + parent.g, parent = parent}
		end
	end 
	if map[y+1][x] == 0 then
		if map[y][x-1] == 0 then
			adj.bottomLeft = { x = x - 1, y = y + 1, g = 14 + parent.g, parent = parent}
		end
		if map[y][x+1] == 0 then
			adj.bottomRight = { x = x + 1, y = y + 1, g = 14 + parent.g, parent = parent}
		end
	end
	adj.up = { x = x, y = y - 1, g = 10 + parent.g, parent = parent}
	adj.left = { x = x - 1, y = y, g = 10 + parent.g, parent = parent}
	adj.right = { x = x + 1, y = y, g = 10 + parent.g, parent = parent}
	adj.down = { x = x, y = y + 1, g = 10 + parent.g, parent = parent}
	return adj
end


function getAdjacentInOpen(currentNode)
	local adj = getAdjacent(currentNode.x, currentNode.y, currentNode)
	local adjInOpen = {}
	for _, adjacent in pairs(adj) do
		for _, node in ipairs(openList) do
			if adjacent.x == node.x and adjacent.y == node.y then
				table.insert(adjInOpen, node)
			end
		end 
	end
	return adjInOpen
end


function checkIfShorter(currentNode, adjacent)
	local adj = getAdjacent(currentNode.x, currentNode.y, currentNode)
	local adjInOpen = getAdjacentInOpen(currentNode)
	if #adjInOpen > 0 then
		for _, openAdjacent in ipairs(adjInOpen) do
			for _, newAdjacent in ipairs(adj) do
				if (openAdjacent.x == newAdjacent.x and openAdjacent.y == newAdjacent.y) then
					local currentG = openAdjacent.g
					local newG = newAdjacent.g  
					if newG < currentG then
						adjacent.parent = currentNode
						adjacent.g = newG
					end
				end
			end
		end
	end
end


function checkWalkable(nodes)
	local walkable = {}
	for _, node in pairs(nodes) do
		if map[node.y][node.x] == 0 then
			table.insert(walkable, node)
		end
	end
	return walkable
end


function addToOpenList(newNodes)
	for _, newNode in pairs(newNodes) do
		alreadyInList = false
		for _, node in ipairs(openList) do
			if node.x == newNode.x and node.y == newNode.y then
				alreadyInList = true
			end
			for _, closedNode in ipairs(closedList) do
				if newNode.x == closedNode.x and newNode.y == closedNode.y then
					alreadyInList = true
				end
			end
		end
		if not alreadyInList then
			table.insert(openList, newNode)
		end
	end
end


function drawOpenList()
	for _, node in ipairs(openList) do
		love.graphics.setColor(0, 0, 125)
		love.graphics.rectangle("fill", node.x * 32, node.y * 32, 32, 32)
		love.graphics.setColor(255, 255, 255)
		-- love.graphics.print(node.parent.x..","..node.parent.y, (node.x * 32) + 3, (node.y * 32) + 3)
		love.graphics.print(getF(node)..","..node.g, (node.x * 32) + 3, (node.y * 32) + 13)
		-- love.graphics.print(node.x..","..node.y, (node.x * 32) + 3, (node.y * 32) + 3)
	end
	love.graphics.setColor(255, 255, 255)
end

function drawClosedList()
	for _, node in ipairs(closedList) do
		love.graphics.setColor(125, 0, 125)
		love.graphics.rectangle("fill", node.x * 32, node.y * 32, 32, 32)
		love.graphics.setColor(255, 255, 255)
		if node.parent then
			love.graphics.print(node.parent.x..","..node.parent.y, (node.x * 32) + 3, (node.y * 32) + 3)
			love.graphics.print(getF(node)..","..node.g, (node.x * 32) + 3, (node.y * 32) + 13)
		end 
	end
	love.graphics.setColor(255, 255, 255)
end


function getH(node)
	local xDifference = 10 * ( math.abs(node.x - endNode.x))
	local yDifference = 10 * ( math.abs(node.y - endNode.y))
	return  xDifference + yDifference
end


function getF(node)
	return node.g + getH(node)
end


function findNextNode()
	local lowestF = 999999999
	local nextNode = nil
	local openIndex = nil 
	for i, node in ipairs(openList) do
		if getF(node) <= lowestF then
			lowestF = getF(node)
			nextNode = node
			openIndex = i
		end
	end	
	return nextNode, openIndex
end


function drawPath()
	love.graphics.setColor(255, 0, 255)
	-- love.graphics.rectangle("fill", nextNode.x * 32, nextNode.y * 32, 32, 32)
	local nodeParent = nextNode.parent
	while not (nodeParent.x == startNode.x and nodeParent.y == startNode.y) do
		love.graphics.rectangle("fill", nodeParent.x * 32, nodeParent.y * 32, 32, 32)
		nodeParent = nodeParent.parent
	end
end

function love.update(dt)
	-- time = time + dt
	-- if time > 0.000005 then
		-- time = time - 1
		if not complete then 
			if not (nextNode.x == endNode.x and nextNode.y == endNode.y) then
				nextNode, openIndex = findNextNode()
				table.insert(closedList, nextNode)
				table.remove(openList, openIndex)
				if #openList == 0 then 
					status = "Not found"
					complete = true
				end
				newAdj = checkWalkable(getAdjacent(nextNode.x, nextNode.y, nextNode))
				addToOpenList(newAdj)
				for _, openNode in ipairs(openList) do
					checkIfShorter(nextNode)
				end
			else
				status = "Found"
				complete = true
			end
			end
	-- end
end

function love.load()
	font = love.graphics.newFont(8)
	love.graphics.setFont(font)
	love.window.setMode(384, 352)
	love.window.setTitle("Pathfinding")
	map = require("map")
	startNode = { x = 4, y = 5, g = 0}
	endNode = { x = 8, y = 5 }
	newX, newY = 0, 0
	mouseX = 0
	reset()
end

function love.keypressed(key)
	if key == "r" then
		reset()
	end
end

function love.mousepressed(x, y, button)
	if button == "l" then
		mouseX = x
		newX = math.floor(x / 32)
		newY = math.floor(y / 32)
		if newY <= #map and newX <= #map[1] and newX > 0 and newY > 0 and not (newX == endNode.x and newY == endNode.y) then
			if map[newY][newX] == 0 then
				setStartPoint(newX, newY)
				reset()
			end
		end
	end
	if button == "r" then
		mouseX = x
		newX = math.floor(x / 32)
		newY = math.floor(y / 32)
		if newY <= #map and newX <= #map[1] and newX > 0 and newY > 0 and not (newX == startNode.x and newY == startNode.y) then
			if map[newY][newX] == 0 then
				setEndPoint(newX, newY)
				reset()
			end
		end
	end
end

function love.draw() 

	love.graphics.setColor(255, 255, 255)
	drawMap()
	love.graphics.setColor(125, 125, 125)
	love.graphics.rectangle("fill", nextNode.x * 32, nextNode.y * 32, 32, 32)
	drawOpenList()
	drawClosedList()
	love.graphics.print(mouseX, 10, 10)
	-- love.graphics.print(status, 10, 10)
	if complete then
		-- drawOpenList()
		-- drawClosedList()
		drawPath()
	end

end