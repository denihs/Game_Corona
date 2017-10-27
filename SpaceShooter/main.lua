
physics = require("physics")

display.newImage("textures/fundo.png",
				display.contentCenterX,
				display.contentCenterY)
player = display.newImage("textures/player.png",100,100)

---------------FILTROS PARA OS OBJETOS---------------------
local filtroBorda = {categoryBits=1, maskBits =2 }
local filtroPlayer = {categoryBits=2, maskBits =21 }
local filtroInimigo = {categoryBits=4, maskBits =14 }
local filtroLaserPlayer = {categoryBits=8, maskBits =4 }
local filtroLaserInimigo = {categoryBitssssssssssdddd=16, maskBits =2 }
-----------------------------------------------------------
 timer.performWithDelay(1200, function ()
 		local angulo = math.random()*math.pi*2
 		criaInimigo(math.cos(angulo)*1000+ display.contentCenterX, 
 			math.sin(angulo)*500 + display.contentCenterY)
 end, 0)

physics.start()
physics.setGravity(0,0)
physics.addBody(player,{ filter = filtroPlayer})

player.vida = 8
display.newImage("textures/playerLife.png",50,50)
player.vidaTexto = display.newText("X"..player.vida,100,52)

player.linearDamping =2
forca = 20

teclas = {}

local borda = display.newRect(0, 0, 0,0)


physics.addBody(borda,"static",{

		chain = {0,0,
				 0, display.contentHeight,
				 display.contentWidth, display.contentHeight,
				 display.contentWidth, 0},
		connectFirstAndLastChainVertex = true,
		filter = filtroBorda
})
print(filtroBorda)

function keyEvent(event)
	if(event.phase == "down") then
		teclas[event.keyName] = true
	else
		teclas[event.keyName] =  false
	end
end 



-------------MOUSE CODIGO--------------------
local somLaser = audio.loadSound("audio/laser4.mp3")
function atira(nave, textura)
	audio.play(somLaser)
	local laser  = display.newImage(textura,nave.x,nave.y)
		  laser.rotation = nave.rotation

		  local filtro
		  if (nave.ehInimigo) then 
		  		filtro =  filtroLaserInimigo
		  	else
		  		filtro  = filtroLaserPlayer
		  end

			physics.addBody(laser, {isSensor  = true, filter = filtro })	


	local dir = {
		x = math.cos(math.rad(laser.rotation)),
		y = math.sin(math.rad(laser.rotation))
	}

	laser.x = laser.x + dir.x*70
	laser.y = laser.y + dir.y*70

	laser:setLinearVelocity(dir.x*1000, dir.y*1000)

	timer.performWithDelay(4000, function()
				display.remove(laser)	
		end, 1)
	--Laser que pulveriza o inimigo
	laser:addEventListener("collision", function(event)
		display. remove (event.target)
		if(event.other.ehInimigo)then
			display.remove(event.other)
			inimigos[event.other] = nil
			timer.cancel(event.other.timer)
		else
			print(player.vida)
			event.other.vida = event.other.vida - 1			
			print(player.vida)
			event.other.vidaTexto.text = "X"..event.other.vida
		end
	end)
end


mouse = {x=0,y=0}
function mouseEvent(event)
	mouse.x = event.x
	mouse.y = event.y
	if(event.isPrimaryButtonDown and event.type == "down") then
			teclas.mouse = true
	elseif(not event.isPrimaryButtonDown) then
			teclas.mouse = false
	end
end

-------------------INIMIGOS---------------
inimigos = {}
function criaInimigo(x,y)
	local inimigo = display.newImage("textures/enemy1.png",x,y)
	physics.addBody(inimigo, { filter = filtroInimigo})

	inimigo.ehInimigo = true
	inimigos[inimigo] = true
	inimigo.timer = timer.performWithDelay(800, function()
			atira(inimigo,"textures/laserRed.png")
	end,0)
end


-----------------------GAMELOOP---------------
freqTiro = 200

ultimoTiro = 0

function gameLoop(event)
	

	if(teclas.w or teclas.up) then
		player:applyForce(0, -forca,player.x,player.y)
	end
	if(teclas.a) then
		player:applyForce(-forca, 0,player.x,player.y)
	end
	if(teclas.s) then
		player:applyForce(0, forca,player.x,player.y)
	end
	if(teclas.d) then
		player:applyForce(forca, 0,player.x,player.y)
	end
	local playerRot = math.atan2(mouse.y-player.y, mouse.x - player.x)
	player.rotation = math.deg(playerRot)
	--Controle da velocidade do tiro
	if(teclas.mouse and event.time - ultimoTiro > freqTiro) then
			ultimoTiro = event.time
			atira(player, "textures/laserBlue.png")
	end
	--Fazer inimigo apontar para o player
	for inimigo in  pairs(inimigos) do
			inimigo.rotation = math.deg(math.atan2(player.y-inimigo.y,
				player.x-inimigo.x))
			local dist = math.sqrt((player.x-inimigo.x)^2 + (player.y-inimigo.y)^2)
			local mod = (dist - 250) / 500
			inimigo:setLinearVelocity((player.x-inimigo.x) * mod,
			(player.y-inimigo.y) * mod)
	end
end



Runtime:addEventListener("key",keyEvent)
Runtime:addEventListener("mouse", mouseEvent)
Runtime:addEventListener("enterFrame", gameLoop)
