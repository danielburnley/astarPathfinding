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


function getMapValue(x, y)
	return map[y][x]
end 


function getAdjacent(x, y, parent)
	return {
		topLeft = { x = x - 1, y = y - 1, g = 14 + parent.g, parent = parent},
		up = { x = x, y = y - 1, g = 10 + parent.g, parent = parent},
		topRight = { x = x + 1, y = y - 1, g = 14 + parent.g, parent = parent},
		left = { x = x - 1, y = y, g = 10 + parent.g, parent = parent},
		right = { x = x + 1, y = y, g = 10 + parent.g, parent = parent},
		bottomLeft = { x = x - 1, y = y + 1, g = 14 + parent.g, parent = parent},
		down = { x = x, y = y + 1, g = 10 + parent.g, parent = parent},
		bottomRight = { x = x + 1, y = y + 1, g = 14 + parent.g, parent = parent}
	}
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
	for _, adjacent in ipairs(adjInOpen) do
		local currentG = adjacent.g
		local newG = (adjacent.g - adjacent.parent.g) + currentNode.g  
		if newG < currentG then
			adjacent.parent = currentNode
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
		love.graphics.print(node.parent.x..","..node.parent.y, (node.x * 32) + 3, (node.y * 32) + 3)
		love.graphics.print(getF(node)..","..node.g, (node.x * 32) + 3, (node.y * 32) + 13)
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
		if getF(node) < lowestF then
			lowestF = getF(node)
			nextNode = node
			openIndex = i
		end
	end	
	return nextNode, openIndex
end


function love.keypressed(key)
	if key == "u" then
		if not (nextNode.x == endNode.x and nextNode.y == endNode.y) then
			nextNode, openIndex = findNextNode()
			table.insert(closedList, nextNode)
			table.remove(openList, openIndex)
			newAdj = checkWalkable(getAdjacent(nextNode.x, nextNode.y, nextNode))
			addToOpenList(newAdj)
			for _, openNode in ipairs(openList) do
				checkIfShorter(nextNode)
			end
		else
			complete = true
		end
	end
end


function drawPath()
	love.graphics.setColor(255, 0, 255)
	love.graphics.rectangle("fill", nextNode.x * 32, nextNode.y * 32, 32, 32)
	local nodeParent = nextNode.parent
	while not (nodeParent.x == startNode.x and nodeParent.y == startNode.y) do
		love.graphics.rectangle("fill", nodeParent.x * 32, nodeParent.y * 32, 32, 32)
		nodeParent = nodeParent.parent
	end
end


function love.load()
	font = love.graphics.newFont(8)
	love.graphics.setFont(font)
	love.window.setMode(384, 384)
	love.window.setTitle("Pathfinding")
	map = require("map")
	startNode = { x = 2, y = 9, g = 0}
	nextNode = startNode
	endNode = { x = 9, y = 9 }
	openList = {}
	closedList = {}
	table.insert(closedList, startNode)
	startAdj = checkWalkable(getAdjacent(startNode.x, startNode.y, startNode))
	addToOpenList(startAdj)
	complete = false
end


function love.draw() 

	love.graphics.setColor(255, 255, 255)
	drawMap()

	drawOpenList()

	love.graphics.setColor(125, 125, 125)
	love.graphics.rectangle("fill", nextNode.x * 32, nextNode.y * 32, 32, 32)
	if complete then
		drawPath()
	end
end