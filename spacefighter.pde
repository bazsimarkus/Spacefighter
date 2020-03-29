import gifAnimation.*;
import controlP5.*;

ControlP5 cp5;

PFont Pixellari18, Pixellari24, Pixellari36, Pixellari48, Pixellari56;
PImage asteroidSprite;
PImage spaceshipSprite;
PImage restartButton;

int score = 0;
boolean dead = false;
boolean rectOver = false;

class Bullet {
  float x;
  float y;
  float z;
  float len;
  float xspeed;

  Bullet() {
    y  = mouseY+39;
    //x  = random(width+50, width+500);
    x  = 135+0.05*mouseX;
    z  = 10;
    len = map(z, 0, 20, 10, 20);
    xspeed  = 20;
  }

  void move() {
    x = x + xspeed/2;
    float grav = map(z, 0, 20, 0, 0.2);
    xspeed = xspeed + grav;

    if (x > width) {
      xspeed  = 20;
    }
  }

  void show() {
    float thick = map(z, 0, 20, 1, 3);
    strokeWeight(6);
    stroke(77, 188, 233);
    line(x, y, x+len, y);
  }
}

class Drop {
  float x;
  float y;
  float z;
  float len;
  float xspeed;

  Drop() {
    x  = width;
    y  = random(height);
    z  = random(0, 20);
    len = map(z, 0, 20, 10, 20);
    xspeed  = map(z, 0, 20, 1, 20);
  }

  void move() {
    x = x - xspeed/8;
    float grav = map(z, 0, 20, 0, 0.2);
    xspeed = xspeed + grav;

    if (x < 0) {
      x = width;
      xspeed = map(z, 0, 20, 4, 10);
    }
  }

  void show() {
    float thick = map(z, 0, 20, 1, 3);
    strokeWeight(thick);
    stroke(180);
    line(x, y, x+len, y);
  }
}

class Asteroid {
  float x;
  float y;
  float z;
  float len;
  float xspeed;
  boolean alive;
  Asteroid() {
    x  = width;
    y  = random(height-95);
    z  = random(0, 20);
    len = map(z, 0, 20, 10, 20);
    xspeed  = map(z, 0, 20, 1, 20);
    alive = true;
  }

  void move() {
    x = x - xspeed/10;
    float grav = map(z, 0, 20, 0, 0.2);
    xspeed = xspeed + grav;

    if (x < 0) {
      x = width;
      xspeed = map(z, 0, 20, 4, 10);
    }
  }

  void show() {
    image(asteroidSprite, x, y, asteroidSprite.width/2, asteroidSprite.height/2);
  }
}

Drop[] drops = new Drop[40];
Bullet[] bullets = new Bullet[20];
Asteroid[] asteroids = new Asteroid[5];

int bulletnum = 0;

void settings() {
  size(displayWidth, displayHeight);
}

Gif myAnimation; 

void setup() {
  fullScreen();

  Pixellari18 = createFont("Pixellari.ttf", 18);
  Pixellari24 = createFont("Pixellari.ttf", 24);
  Pixellari36 = createFont("Pixellari.ttf", 36); 
  Pixellari48 = createFont("Pixellari.ttf", 48);
  Pixellari56 = createFont("Pixellari.ttf", 56);
  textFont(Pixellari24);

  cp5 = new ControlP5(this);

  myAnimation = new Gif(this, "spaceship1.gif");  
  myAnimation.play();

  setObjects();

  asteroidSprite = loadImage("asteroid1.png");
  spaceshipSprite = loadImage("spaceship1.gif");
  restartButton = loadImage("restartbutton.png");
}

void draw() {
  if (dead==false) {
    background(0, 0, 0);

    strokeWeight(4);
    fill(255);
    textFont(Pixellari24);
    text(bulletnum, 40, 40);
    text("Pontszám:", width-180, 40);
    text(score, width-40, 40);
    stroke(255);
    fill(0, 0, 0);
    image(myAnimation, 10 + 0.05*mouseX, mouseY);
    // image(spaceshipSprite, 50, mouseY, spaceshipSprite.width/1, spaceshipSprite.height/1);
    // quad(50, mouseY + 0, 100,mouseY + 20, 50,mouseY + 40, 70,mouseY + 20);
    for (int i = 0; i < drops.length; i++) {
      drops[i].move();
      drops[i].show();
    }

    for (int i = 0; i < asteroids.length; i++) {
      if (asteroids[i].alive==true) { 
        asteroids[i].move();
        asteroids[i].show();
      }
    }

    for (int i = 0; i < bulletnum; i++) {

      if (bullets[i].x>width) {
        bulletnum = bulletnum-1;
        //   bullets[i] = new Bullet();
        for (int j = 0; j < bullets.length-1; j++) {
          bullets[j]=bullets[j+1];
        }
        //  bullets[i].x = 50;
      }
    }
    for (int i = 0; i < bulletnum; i++) {

      bullets[i].move();
      bullets[i].show();
    }


    //collision check of asteroid and bullet
    for (int i = 0; i < asteroids.length; i++) {
      for (int j = 0; j < bulletnum; j++) {
        if (
          bullets[j].x > asteroids[i].x &&
          bullets[j].y < (asteroids[i].y+95) &&
          bullets[j].y > asteroids[i].y) { //collision vizsgálat az aszteroida és a lövedékek között, végigpörgetem mindkét osztály ciklusait
          //    asteroids[i].alive=false; 
          bullets[j]= new Bullet();
          bulletnum=bulletnum-1;
          asteroids[i] = new Asteroid();
          score++;
        }
      }
    }

    //game over
    for (int i = 0; i < asteroids.length; i++) {
      if (asteroids[i].x < 5 ||
        ((asteroids[i].x <135) && (asteroids[i].y > mouseY) && (asteroids[i].y < mouseY + 125))) { //collision vizsgálat az aszteroida és a lövedékek között, végigpörgetem mindkét osztály ciklusait
        dead = true;
      }
    }
  } else {
    rectOver = overRect(width/4-200, height/2-200, 400, 400);
    background(0, 0, 0);
    fill(255);
    image(restartButton, width/4-200, height/2-200, 400, 400);
    // rect(20,20,40,40);
    // change the trigger event, by default it is PRESSED.
    textFont(Pixellari56);
    text("Game Over", 3*width/4-200, 100);

    textFont(Pixellari24);
    text("Az elért pontjaid száma: ", 3*width/4-200, 200);
    textFont(Pixellari56);
    text(score, 3*width/4-200, 250);

    textFont(Pixellari36);
    text("Nyomd meg a gombot", 3*width/4-200, 400);
    text("a játék újraindításához", 3*width/4-200, 450);
  }
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void setObjects() {
  score = 0;
  for (int i = 0; i < drops.length; i++) {
    drops[i] = new Drop();
  }
  for (int i = 0; i < bullets.length; i++) {
    bullets[i] = new Bullet();
  }
  for (int i = 0; i < asteroids.length; i++) {
    asteroids[i] = new Asteroid();
  }
};

void mouseClicked() { // az egergomb lenyomasakor lefuto fuggveny
  if (dead == false) { 
    if (bulletnum<9) { //egyszerre csak 9 bullet lehet a palyan hogy ne legyen sorozatklikkeles
      bulletnum = bulletnum + 1;
      bullets[bulletnum]= new Bullet();
      bullets[bulletnum-1].y=mouseY+39; //mindig az elozore kell ugrani mert valamiert a kovetezo loves kapta csak meg az eger adatat
      // bullets[bulletnum].x=100;
    }
  }
  if (rectOver & dead == true) {
    dead = false;
    setObjects();
  }
  // bullets[bulletnum] = new Bullet();
}