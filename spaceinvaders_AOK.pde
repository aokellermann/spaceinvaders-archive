/*Antony Kellermann
 SPACE INVADERS
 
 Use LEFT/RIGHT to move ship.
 Press SPACE to shoot.
 Kill everything to win.
 You have three lives.
 
 */
//loading sound
import ddf.minim.*;
Minim minim;
AudioPlayer failuresound;
AudioPlayer congradulations;
AudioPlayer suddenDeath;
PImage basic;//basic alien
PImage ship;
PImage failure;
PImage success;
PImage blueAlien;//final boss image
float alienXSpeed = 10;//starting alien x speed
int gameState=0;//0 is start 1 is level 1 2=2 3=3 4=fail 5=win
int left;//to move ship left/right smoothly
int right;
int shoot=0;//to shoot
int shipX=600;//ship starts in middle
int canShoot = 1;//1 = can shoot
int shootTimer=10;//time between shots
int alienShootTimer=10;
int finalBossShootTimer=5;
int lives=2;//player has 3 total lives
int randomAlien=4;//for making a random alien shoot
int deadAliens=0;//# of dead aliens; 5=level up
int finalBossX;//x of final boss
int finalBossY;//y of final boss
float finalBossDamage;//how much damage has the final boss taken
float alienSpeedCounter=1;//slowly increases making aliens faster as they move down screen
int [] alienAlive;//if alien is alive or not
int [] shipBulletAlive;//if ship bullet is alive or not
int [] alienBulletAlive;//if alien bullet is alive or not
int [] shipShotX;//x of ship bullet
int [] shipShotY;//y of ship bullet
int [] alienShotX;//x of alien bullet
int [] alienShotY;//y of alien bullet
int [] finalBossShotX;//x of final boss bullets
int [] finalBossShotY;//y of final boss bullets
int [] finalBossBulletAlive;//is the final boss bullet alive or not
float [] alienX;//alien x 
int [] alienY;//alien y
boolean playOnce = false;//for sound stuff
final static int BOSSSIZEX = 162;//for measuring if boss gets hit by ship (total width/2)
final static int BOSSSIZEY = 100;
final static int SHOTV = -20;//ship velocity
final static int SHIPY = 650;//ship y
final static int OBJECTSIZE = 30;//space so ship stays on screen
final static int BULLETSIZE = 10;//radius of bullet
final static int DEAD = 0;//alien dead or alive?
final static int ALIVE = 1;
final static int START = 0;//gamestates
final static int LEVEL1 = 1;
final static int LEVEL2 = 2;
final static int FINALBOSS = 3;
final static int LOSE = 4;
final static int WIN = 5;
final static int FPS = 15;
void setup () {
  alienX = new float [5];//5 aliens per level
  alienY = new int [5];
  alienAlive = new int [5];
  shipShotX = new int [0];//0 bullets to start withFc
  shipShotY = new int [0];
  alienShotX = new int [0];
  alienShotY = new int [0];
  shipBulletAlive = new int [0];
  alienBulletAlive = new int [0];
  finalBossBulletAlive = new int [0];
  finalBossShotX = new int [0];
  finalBossShotY = new int [0];
  size (1200, 700);
  background (0);
  smooth ();
  textAlign (CENTER, CENTER);
  imageMode (CENTER);
  frameRate (FPS);
  //loading and resizing images
  failure = loadImage ("Failure.jpg");
  success = loadImage ("success.jpg");
  basic = loadImage ("basic.jpg");
  basic.resize (65, 65);
  ship = loadImage ("spaceship.png");
  ship.resize (100, 100);
  blueAlien = loadImage ("bluealien.jpg");
  blueAlien.resize (325, 200);
  //loading sound
  minim = new Minim(this);
  failuresound = minim.loadFile("failure.mp3");
  congradulations = minim.loadFile("congradulations.mp3");
  suddenDeath = minim.loadFile("suddendeath.mp3");
}
void draw () {
  background (0);//black backround
  if (left==1)//moving the ship left and right
    shipX=shipX-20;
  if (right==1)
    shipX=shipX+20;
  if (shipX<OBJECTSIZE)//boundaries of game
    shipX=OBJECTSIZE;
  if (shipX>width-OBJECTSIZE)
    shipX=width-OBJECTSIZE;
  if ((shoot==1) && (canShoot==1)) {//puts timer between ship shots (can"t spam shoot)
    shipShoot ();
    canShoot=0;
    shootTimer=10;
  } 
  if (canShoot==0)
    shootTimer--;
  if (shootTimer==0)
    canShoot=1;
  for (int i=0; i<shipShotX.length; i++) {//draws ship bullets
    shipShotY [i]+= SHOTV;//sets bullet speed
    if (shipBulletAlive[i]==1)
      ellipse (shipShotX [i], shipShotY[i], BULLETSIZE, BULLETSIZE);
  }
  for (int i=0; i<alienShotX.length; i++) {//draws alien bullets
    alienShotY [i]-= SHOTV;//sets bullet speed
    if (alienBulletAlive[i]==1)
      ellipse (alienShotX [i], alienShotY[i], BULLETSIZE, BULLETSIZE);
  }
  for (int i=0; i<shipShotX.length; i++) {//aliens die when they get hit
    for (int k=0; k<alienX.length; k++) {
      if (((((shipShotX[i]<=alienX[k]+33) && (shipShotX[i]>=alienX[k]-33) && (shipShotY[i]<=alienY[k]+33) && (shipShotY[i]>=alienY[k]-33) && (alienAlive[k]==1))))) {
        alienAlive[k]=0;
        shipBulletAlive[i]=0;//bullet can't hit you again
        deadAliens++;
      }
    }
  }
  for (int i=0; i<alienShotX.length; i++) {//player loses lives if hit
    if (((((alienShotX[i]<=shipX+OBJECTSIZE) && (alienShotX[i]>=shipX-OBJECTSIZE) && (alienShotY[i]<=SHIPY+OBJECTSIZE) && (alienShotY[i]>=SHIPY-OBJECTSIZE) && (alienBulletAlive[i]==1))))) {
      alienBulletAlive[i]=0;//bullet can't hit you again
      lives--;
    }
  }
  if (gameState==START) {//start screen
    textSize(50);
    text ("Press the space bar to start!", width/2, 500);
  }
  if ((gameState==LEVEL1) || (gameState==LEVEL2)) {//first two levels 
    fill (255);
    textSize(16);
    text ("x" + lives, 60, 35);//shows how many lives left
    image (ship, 35, 35, 40, 40);
    alienSpeedCounter+=0.005;//speed of aliens go up (aliens get faster)
    image (ship, shipX, SHIPY, 100, 100);
    textSize (32);
    text ("LEVEL " + gameState, width/2, 30);//tells you which level you're on
    for (int i=0; i<alienX.length; i++) { //aliens move down screen
      alienX[i]=alienX[i] + alienXSpeed * alienSpeedCounter;//sets aliens speed
      if (((alienX[i]>=width-OBJECTSIZE) || (alienX[i]<=OBJECTSIZE)) && (alienAlive[i]==1))//if end of screen, move down
        moveDown ();
    }

    for (int i=0; i<alienX.length; i++) { //if alien alive, draw image
      if (alienAlive[i] == 1)
        image (basic, alienX[i], alienY[i], 65, 65);//draws alien
    }
    for (int i =0; i<alienY.length; i++) {//if alien gets to bottom of screen
      if (alienY[i]>=SHIPY-OBJECTSIZE)
        gameState=LOSE;//lose screen
    }
  }
  if ((gameState==LEVEL1) && (deadAliens==5))
    spawnAliens();//if all aliens are dead, advance level

  if (gameState==LEVEL2) {//level 2
    if (alienShootTimer==0) {//time between alien shots
      alienShoot();
      alienShootTimer=10;
    }
    if (deadAliens==5)//if all aliens are dead, advance to final boss
      gameState=FINALBOSS;
    randomAlien=int(random(5));// get random alien
    if (deadAliens<5) {// while that alien is dead, get a different random alien
      while (alienAlive[randomAlien]==DEAD)
        randomAlien = int (random (5)); // get another random alien and try again
    }
    alienShootTimer--;//time in btw shots
  }

  if (gameState==FINALBOSS) {
    image (ship, shipX, SHIPY, 100, 100);
    fill (255, 0, 0);
    textSize(24);
    text ("Health", 975, 20);//shows health of final boss
    fill (255);
    textSize(16);
    text ("x" + lives, 60, 35);//shows how many lives player has left
    image (ship, 35, 35, 40, 40);
    if (playOnce == false) {//plays sudden death sound
      suddenDeath.play();
      playOnce = true;
    }
    finalBossMove();//moves boss in an oval
    finalBossShootTimer--;//time in btw shots
    if (finalBossShootTimer==0) {
      finalBossShoot();
      finalBossShootTimer=5;
    }
    for (int i=0; i<finalBossShotX.length; i++) {//draws boss bullets
      finalBossShotY [i]-= SHOTV;
      if (finalBossBulletAlive[i]==1)
        ellipse (finalBossShotX [i], finalBossShotY[i], BULLETSIZE, BULLETSIZE);
    }
    for (int i=0; i<finalBossShotX.length; i++) {//player loses lives if hit
      if (((((finalBossShotX[i]<=shipX+OBJECTSIZE) && (finalBossShotX[i]>=shipX-OBJECTSIZE) && (finalBossShotY[i]<=SHIPY+OBJECTSIZE) && (finalBossShotY[i]>=SHIPY-OBJECTSIZE) && (finalBossBulletAlive[i]==1))))) {
        finalBossBulletAlive[i]=0;
        lives--;
      }
    }
    for (int i=0; i<shipShotX.length; i++) {//boss takes damage when hit
      if (((((shipShotX[i]<=finalBossX+BOSSSIZEX) && (shipShotX[i]>=finalBossX-BOSSSIZEX) && (shipShotY[i]<=finalBossY+BOSSSIZEY) && (shipShotY[i]>=finalBossY-BOSSSIZEY) && (shipBulletAlive[i]==1))))) {
        shipBulletAlive[i]=0;
        finalBossDamage--;
      }
    }
    fill (0, 0, 255);
    rect (1150, 50, -350-(17.5*finalBossDamage), 50);//health bar for final boss
    fill (255);
    if (finalBossDamage==-20) {//win sound
      congradulations.rewind();
      congradulations.play();
      gameState=WIN;
    }
  }
  if (gameState < 4 && lives==-1) {//lose sound
    gameState=LOSE;
    failuresound.rewind();
    failuresound.play();
  }
  if (gameState==LOSE) 
    image (failure, width/2, 300);//lose picture

  if (gameState==WIN) {
    image (success, width/2, 300);//win picture
  }
}
void shipShoot () {//ship shoots when you press space
  shipShotX = append (shipShotX, 1);
  shipShotY = append (shipShotY, 1);//appends the arrays
  shipBulletAlive = append (shipBulletAlive, 1);
  for (int i=0; i<shipShotX.length; i++)
    shipShotX[shipShotX.length-1] = shipX;
  for (int i=0; i<shipShotY.length; i++)//changes the value that was just added
    shipShotY[shipShotY.length-1] = width/2;//     to (shipX, width/2)
  for (int i=0; i<shipBulletAlive.length; i++)
    shipBulletAlive[shipBulletAlive.length-1] = 1;
}
void alienShoot () {//aliens shoot in level 2
  alienShotX = append (alienShotX, 1);
  alienShotY = append (alienShotY, 1);//appends the arrays
  alienBulletAlive = append (alienBulletAlive, 1);
  for (int i=0; i<alienShotX.length; i++)
    alienShotX[alienShotX.length-1] = int(alienX[randomAlien]);
  for (int i=0; i<alienShotY.length; i++)
    alienShotY[alienShotY.length-1] = alienY[randomAlien];
  for (int i=0; i<shipBulletAlive.length; i++)
    alienBulletAlive[alienBulletAlive.length-1] = 1;
}
void spawnAliens () {//when all aliens die, runs
  for (int i=0; i<alienX.length; i++) {//starting pos of aliens
    alienX[i]=200 * i + 200;//spacing of aliens
    alienY[i]=100;
    alienAlive[i]=1;//all are alive
  }
  deadAliens=0;//resets dead aliens
  gameState++;//advances level
  alienSpeedCounter=1;//resets speed
}
void moveDown () {//aliens move down screen
  for (int i=0; i<alienX.length; i++)
    alienX[i]-=alienXSpeed;//reverses alien direction
  for (int k=0; k<alienY.length; k++)
    alienY[k]+=50;//move down
  alienXSpeed=-alienXSpeed;//switch directions
}
void finalBossMove () {//moves final boss along a spline (oval shape)
  float t = millis()/500.0;
  int radiusX = 225;
  int radiusY =  75;
  finalBossX = (int)(width/2+radiusX*cos(t));
  finalBossY = (int)(height/4+radiusY*sin(t));
  image (blueAlien, finalBossX, finalBossY, 325, 200);
}
void finalBossShoot() {//final boss shooting
  finalBossShotX = append (finalBossShotX, 1);
  finalBossShotY = append (finalBossShotY, 1);//appends the arrays
  finalBossBulletAlive = append (finalBossBulletAlive, 1);
  for (int i=0; i<finalBossShotX.length; i++)
    finalBossShotX[finalBossShotX.length-1] = finalBossX;
  for (int i=0; i<finalBossShotY.length; i++)
    finalBossShotY[finalBossShotY.length-1] = finalBossY + 65;//add 65 so the bullet appears where his mouth is
  for (int i=0; i<finalBossBulletAlive.length; i++)
    finalBossBulletAlive[finalBossBulletAlive.length-1] = 1;
}
void keyPressed () {
  if (keyCode==LEFT)//if key pressed, move ship
    left=1;
  if (keyCode==RIGHT)
    right=1;
  if ((key==' ') && (gameState!=START))
    shoot=1;
  if (key=='k') {//kills all aliens (for testing purposes)
    deadAliens=5;
    if (gameState==FINALBOSS)
      finalBossDamage=-20;
  }
  if ((key==' ') && (gameState==START)) 
    spawnAliens();
}
void keyReleased () {
  if (keyCode==LEFT) //if key release, dont move/shoot
    left=0;
  if (keyCode==RIGHT) 
    right=0;
  if (key==' ')
    shoot=0;
}


