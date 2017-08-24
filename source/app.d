import std.stdio;
import std.math;
import std.conv;
import Dgame.Window;
import Dgame.Window.Event;
import Dgame.System.Keyboard;
import Dgame.System.Font;
import Dgame.Graphic;
import Dgame.Math;
import Dgame.System.StopWatch;


void main()
{
    Window wnd = Window(1000, 800, "Lunar Lander - Dgame");
    StopWatch clockdt;
    float last_delta = 0;
    float delta = 0;
    Font fnt = Font("fonts/LiberationSans-Regular.ttf", 22);
    Font fntGO = Font("fonts/LiberationSans-Regular.ttf", 72);
	Text txtAlt = new Text(fnt);
	Text txtSpeed = new Text(fnt);
	Text txtFuel = new Text(fnt);
	Text txtReset = new Text(fnt);
	Text txtGameOver = new Text(fntGO);
    txtSpeed.setPosition(0, 30);
    txtFuel.setPosition(0, 60);
    txtReset.setPosition(0, 90);
    txtGameOver.setPosition(280, 300);
    float gravity = 1.622;
    bool gameover = false;
    Rect EarthRect;


    struct Player
    {
        static immutable int width = 77, height = 80;
        Rect rect;
        static immutable string image = "player.png";
        Texture img;
        Sprite player;
        int moveSpeed = -2;
        float vSpeed = 0;
        float hSpeed = 0;
        float fuel = 3000;
        float altitude = 514;
        float aceleration = 1.622;
        float hAceleration = 2;
        float time = 0;
        float v0 = 0;
        float hv0 = 0;
        bool acelerating = false;
        int direction = 0;
        bool colliding = false;

        void create()
        {
            img = Texture(Surface(Player.image));
            player = new Sprite(img);
            player.setPosition(20, 50);
            rect = Rect(20, 50, 77, 80);
        }

        void reset()
        {
            vSpeed = 0;
            hSpeed = 0;
            fuel = 3000;
            altitude = 514;
            time = 0;
            v0 = 0;
            hv0 = 0;
            acelerating = false;
            direction = 0;
            colliding = false;
            player.setPosition(20, 50);
            rect.setPosition(cast(int)player.x, cast(int)player.y);
            gameover = false;
        }

        // Called once per frame
        void update(ref Window wnd)
        {
            // colision
            if (rect.intersects(EarthRect))
            {
                colliding = true;
                if (vSpeed > 8.0)
                {
                    gameover = true;
                    writeln("explodes!");
                }
            }
            else
            {
                colliding = false;
            }

            // When the fuel runs out
            if (fuel <= 0.0)
            {
                fuel = 0.0;
                acelerating = false;
                direction = 0;
            }
            // aceleration / gravidade
            if (acelerating)
            {
                aceleration = moveSpeed;
                fuel -= 10 * delta;
            }
            else if (!colliding)
            {
                aceleration = gravity;
            }
            else
            {
                aceleration = 0;
            }

            // vertical velocity
            vSpeed = v0 + aceleration * delta;
            v0 = vSpeed;
            if (colliding && vSpeed > 0)  // do chão não passa
            {
                vSpeed = 0;
                v0 = 0;
            }
            move(0, to!int(vSpeed));
            altitude -= vSpeed * delta;

            // horizontal velocity
            if (!colliding)
            {
                hSpeed = hv0 + (hAceleration*direction) * delta;
                hv0 = hSpeed;
                move(to!int(hSpeed), 0);
            }
            else
            {
                hSpeed = hv0 + (hAceleration*direction) * delta;
                hv0 = hSpeed * 0.999;
                move(to!int(hSpeed), 0);
            }

            // fuel combustion
            if (direction != 0)
            {
                fuel -= 5 * delta;
            }

            // draw
            wnd.draw(player);
        }

        void move(int x, int y)
        {
            player.move(x*delta, y*delta);
            rect.setPosition(cast(int)player.x, cast(int)player.y);
        }
    }

    // initializing
    Shape Earth = new Shape(Geometry.Quads,
        [
            Vertex( 75,  75),
            Vertex(800,  75),
            Vertex(800, 800),
            Vertex( 75, 800)
        ]
    );
    EarthRect = Rect(75, 800-170, 800-75, 75);
    Earth.fill = Shape.Fill.Full;
    Earth.setColor(Color4b.Blue);
    Earth.setPosition(0, 550);
    Player player = Player();
    player.create();
    bool running = true;
    txtReset.format("Press R to reset");

    // Main game loop
    Event event;
    while (running)
    {
        clockdt.reset();
        wnd.clear();

        // Events
        while (wnd.poll(&event))
        {
            switch (event.type)
            {
                case Event.Type.Quit:
                    writeln("Quit Event");
                    running = false;
                break;

                case Event.Type.KeyDown:  // evento tecla (não gameplay)
                    if (event.keyboard.key == Keyboard.Key.Esc)
                        running = false; // or: wnd.push(Event.Type.Quit);
                    else if (event.keyboard.key == Keyboard.Key.R)
                        player.reset();
                break;

                default: break;
            }
        }

        // Gameplay, realtime
        if (Keyboard.isPressed(Keyboard.Code.Right))
            player.direction = 1;
        if (Keyboard.isPressed(Keyboard.Code.Left))
            player.direction = -1;
        if (!Keyboard.isPressed(Keyboard.Code.Left) && !Keyboard.isPressed(Keyboard.Code.Right))
            player.direction = 0;
        if (Keyboard.isPressed(Keyboard.Code.Up) || Keyboard.isPressed(Keyboard.Code.Space))
            player.acelerating = true;
        else
            player.acelerating = false;


        // Draw update
        player.update(wnd);
        wnd.draw(Earth);
        txtAlt.format("Altitude: %d", to!int(player.altitude));
        txtSpeed.format("Speed: %s", to!string(player.vSpeed));
        txtFuel.format("Fuel: %s", to!string(player.fuel));
        if (gameover)
        {
            txtGameOver.format("GAME OVER");
            wnd.draw(txtGameOver);
        }
		wnd.draw(txtAlt);
		wnd.draw(txtSpeed);
		wnd.draw(txtFuel);
		wnd.draw(txtReset);
        wnd.display();
        // deltatime
        delta = abs(clockdt.getElapsedTime().msecs - last_delta) / 100;
        last_delta = delta;
    }
}
