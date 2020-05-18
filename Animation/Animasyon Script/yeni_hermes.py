from turtle import *
from time import sleep

screen = Screen()
screen.setup(1251,251)

screen.addshape("ambulans.gif")
screen.addshape("araba1.gif")
screen.addshape("araba2.gif")
screen.addshape("araba3.gif")
screen.addshape("araba4.gif")
screen.addshape("araba5.gif")

ambulans = Turtle()
araba1 = Turtle()
araba3 = Turtle()

while 1:
    araba1.shape("araba5.gif")
    araba3.shape("araba4.gif")
    ambulans.shape("ambulans.gif")

    ambulans.speed(50)
    araba1.speed(50)
    araba3.speed(50)

    ambulans.penup()
    araba1.penup()
    araba3.penup()

    ambulans.goto(-590,-8)
    araba1.goto(-120,-10)
    araba3.goto(-10,100)
    araba3.seth(270)
    screen.update()
    screen.bgpic("bg1.gif")
    
    timer = 0
    
    while timer < 700:
        timer = timer + 1
        ambulans.forward(2)
        
        if timer == 140:
            screen.update()
            screen.bgpic("bg2.gif")
            
        if timer == 350:
            araba3.goto(500,125)
            screen.update()
            screen.bgpic("bg4.gif")
            
        if timer == 370:
            screen.update()
            screen.bgpic("bg3.gif")
            
        if timer == 580:
            screen.update()
            screen.bgpic("bg1.gif")
            
        if timer < 250:
            araba3.forward(1)

        if timer > 140 and timer < 310:
            araba1.forward(3)

        if timer > 320 and timer < 370:
            araba3.forward(2)

        if timer > 370 and timer < 480:
            araba1.forward(3)

        if timer > 580:
            araba3.forward(3)
            
        print(timer)
    
