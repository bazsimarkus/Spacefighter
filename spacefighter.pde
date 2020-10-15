/*
 * Spacefighter
 * This is a 8-bit style PC/Android game inspired by the classic game Asteroids, written in Processing 3. 
 */

//gifAnimation library by extrapixel - for the animated spaceship GIF import - if we replace the spacheship with a static image file, this library can be neglected
import gifAnimation.*;

PFont Pixellari18, Pixellari24, Pixellari36, Pixellari48, Pixellari56;
PImage asteroidSprite;
PImage spaceshipSprite;
PImage restartButton;

// some globals
int score = 0;
boolean dead = false;
boolean rectOver = false;

// bullet class, the spaceship shoots it
class Bullet {
  float x;
  float y;
  float z;
  float len;
  float xspeed;

  Bullet() {
    y  = mouseY+39;
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
    strokeWeight(6);
    stroke(77, 188, 233);
    line(x, y, x+len, y);
  }
}

// for the background star animation, we create little droplet-like objects, which move from the right side of the screen to the left, thus creating a dynamic effect
class Star {
  float x;
  float y;
  float z;
  float len;
  float xspeed;

  Star() {
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

    //if the stars run out of the screen, we move them back to the right side
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


// enemy class
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
  }

  void show() {
    image(asteroidSprite, x, y, asteroidSprite.width/2, asteroidSprite.height/2);
  }
}

// the elements on the screen
Star[] stars = new Star[40];
Bullet[] bullets = new Bullet[20];
Asteroid[] asteroids = new Asteroid[5];

int bulletnum = 0;

void settings() {
  size(displayWidth, displayHeight);
  fullScreen();
}

Gif myAnimation; 

void setup() {  
  Pixellari18 = createFont("Pixellari.ttf", 18);
  Pixellari24 = createFont("Pixellari.ttf", 24);
  Pixellari36 = createFont("Pixellari.ttf", 36); 
  Pixellari48 = createFont("Pixellari.ttf", 48);
  Pixellari56 = createFont("Pixellari.ttf", 56);
  textFont(Pixellari24);

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
    text("Score:", width-180, 40);
    text(score, width-40, 40);
    stroke(255);
    fill(0, 0, 0);
    image(myAnimation, 10 + 0.05*mouseX, mouseY);
    
    // move the stars in the background
    for (int i = 0; i < stars.length; i++) {
      stars[i].move();
      stars[i].show();
    }

    // move the asteroids
    for (int i = 0; i < asteroids.length; i++) {
      if (asteroids[i].alive==true) { 
        asteroids[i].move();
        asteroids[i].show();
      }
    }

    //decrease the bullet number if a bullet leaves the screen
     for (int i = 0; i < bulletnum; i++) {
      if (bullets[i].x>width) {
        bulletnum = bulletnum-1;
        for (int j = 0; j < bullets.length-1; j++) {
          bullets[j]=bullets[j+1];
        }
      }
    }
    
    //move the bullets
    for (int i = 0; i < bulletnum; i++) {
      bullets[i].move();
      bullets[i].show();
    }

    //collision check of asteroid and bullet, if the bullet hits an asteroid, we remove it, and generate a new one on the right side of the screen
    for (int i = 0; i < asteroids.length; i++) {
      for (int j = 0; j < bulletnum; j++) {
        if (
          bullets[j].x > asteroids[i].x &&
          bullets[j].y < (asteroids[i].y+95) &&
          bullets[j].y > asteroids[i].y) { //iterate over both
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
        ((asteroids[i].x <135) && (asteroids[i].y > mouseY) && (asteroids[i].y < mouseY + 125))) { //collision check
        dead = true;
      }
    }
  } else {
    rectOver = overRect(width/4-200, height/2-200, 400, 400);
    background(0, 0, 0);
    fill(255);
    image(restartButton, width/4-200, height/2-200, 400, 400);
    
    textFont(Pixellari56);
    text("Game Over", 3*width/4-200, 100);

    textFont(Pixellari24);
    text("Your score: ", 3*width/4-200, 200);
    textFont(Pixellari56);
    text(score, 3*width/4-200, 250);

    textFont(Pixellari36);
    text("Press the big button", 3*width/4-200, 400);
    text("to start a new game", 3*width/4-200, 450);
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
  for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star();
  }
  for (int i = 0; i < bullets.length; i++) {
    bullets[i] = new Bullet();
  }
  for (int i = 0; i < asteroids.length; i++) {
    asteroids[i] = new Asteroid();
  }
};

void mouseClicked() { // runs when mouse clicked
  if (dead == false) { 
    if (bulletnum<9) { //only 9 bullets on the screen at once
      bulletnum = bulletnum + 1;
      bullets[bulletnum]= new Bullet();
      bullets[bulletnum-1].y=mouseY+39; //jump back to give the command to the right bullet
    }
  }
  if (rectOver & dead == true) {
    dead = false;
    setObjects();
  }
}
