/*ICS2O Final Summative Evaluation
 By Gordon Lin and Daniel Weng
 */

//Set memory limit to 4096, as this uses a lot of RAM

int currentScene = 0;//shows what is on screen: 0 - main menu, 1 - game, 2 - shop, 3 - credits, 4 - exit
//initializing all fonts
PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];


String[] saveData = {"0", "0", "0", "0", "0", "0", "0", "0"}; //0th value: past distance, 1st value: gun type, 2nd value: armour type, 3rd value: money, 4th value: top gun purchased, 5th value: top armour purchased, 6th value: top jetpack, 7th value: jetpack

//creating image variables
PImage[] character = new PImage[5];//player image
PImage bullet;//bullet image
PImage[] obstacleImages = new PImage[2];//obsatcle image
PImage[] robot = new PImage[3];//robot image
PImage mainMenuPic;
PImage[][] guns = new PImage[20][];
PImage armour;
PImage rocket;
PImage coin;

int[] reloadTime = {1500, 2500, 2750, 2000, 3500, 3500, 4250, 3500, 3250, 3000, 2750, 2750, 2250, 2500, 4500, 4600, 6000, 6250, 10000, 10000};//shows reload time for all guns
boolean[] auto = {false, false, true, true, false, false, true, true, false, true, true, true, true, true, false, false, true, true, false, false}; //if guns are either auto or semi-auto

//initializing gravity
int JUMPPOWER=-12;
float gravity=0.6;
boolean jump=false;

//position of player
float pos[] = {500.0, 0.0};

float vy=0;//vertical speed

int[] fireRate = {0, 0, 250, 250, 100, 100, 250, 150, 100, 100, 100, 100, 50, 100, 0, 0, 100, 100, 0, 0}; //fire rate of each gun
int[] bullets = {12, 7, 25, 32, 8, 8, 32, 50, 30, 30, 30, 30, 30, 30, 1, 10, 150, 150, 1, 1};//bullet capacity
int[] dmg = {25, 40, 30, 25, 50, 55, 40, 35, 35, 40, 35, 40, 40, 50, 200, 250, 30, 40, 1000, 2000};//bullet damage
int[] robotReload = {1000, 1250, 500, 500, 250, 250, 500, 500, 750, 500, 500, 500, 500, 500, 4500, 1000, 350, 350, 10000, 10000};//shows reload time for robots
int bulletsRemaining = 0;//bullets remaining

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();//2D list for trail

float distTravelled=0;//current distance travelled
float speed=1;//current speed
float speedUp=0.1;//increasing speed

PImage background[] = new PImage[3];//background image

float[][] groundPos = {{0, height+400}, {1280, height+random(-75, 75)+400}};//shows ground position

//initializing information about ground
float topOfGrass = 0;
float topOfNextGrass = 0;
int nextGround = 0;
int current = 0;
float bottomOfPlayer = 0;
boolean onGround = true;
boolean colliding = false;
boolean gap = false;

float speedBoost;
float maxFuel;
float maxHealth;
float health;
float fuel;
ArrayList<ArrayList<Float>> coins = new ArrayList<ArrayList<Float>>();//2D list for coins

boolean onObstacle = false;//on or off obstacle
float topOfObstacle = 0;
float rightOfObstacle = 0;

float[] scaleFactor = {1, 1, 1, 1}; //0-main scaling factor, 1-scale for background and sky, 2-x scale, 3-y scale

void scaling(){
  scaleFactor[2] = float(width)/1280.0;
  scaleFactor[3] = float(height)/720.0;
  if (scaleFactor[2] > scaleFactor[3]){
    scaleFactor[0] = scaleFactor[3];
    scaleFactor[1] = scaleFactor[2];
  }
  else{
    scaleFactor[0] = scaleFactor[2];
    scaleFactor[1] = scaleFactor[3];
  }
}

void movePlayer() {
  bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;//finds bottom of player
  pos[1]+=vy*scaleFactor[0];//moving the player up/down
  for (int i = 0; i < 2; i++){
    if (pos[0]>= groundPos[i][0] && pos[0]<= groundPos[i][0]+background[0].width) current = i;//finds the ground the player's on
  }
  nextGround = (current+1)%2;
  topOfGrass = groundPos[current][1]+(49*scaleFactor[1]);
  topOfNextGrass = groundPos[nextGround][1]+(49*scaleFactor[1]);
  if (onGround) pos[1]=topOfGrass-(character[0].height/3+character[2].height);
  else if (onObstacle) pos[1] = topOfObstacle - (character[0].height/3+character[2].height);
  else vy+=gravity;
  if (groundPos[nextGround][0]-(int(speed)/3+1)*scaleFactor[1] <= pos[0]+character[0].width/2 && bottomOfPlayer-topOfNextGrass >= 10*scaleFactor[1] && groundPos[nextGround][0] > 0){
    pos[0]-= (int(speed)/3+6)*scaleFactor[1];
    colliding = true;
  }
  else{
    colliding = false;
  }
  if (pos[0] < width*(500/1280) && pos[0]>0){
    pos[0]++;//run back to original position
  }
  if (!onGround && bottomOfPlayer >= topOfGrass && !justJumped){//checking if on ground
    vy = 0;
    onGround = true;
  }
  for (int i = 0; i < obstacles.size(); i++){
    float top = obstacles.get(i).get(1);//top of obstacle
    float left = obstacles.get(i).get(0)-obstacleImages[int(obstacles.get(i).get(2))].width/3;//left of obstacle
    float right = obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].width/3;//right of obstacle
    float futureLeft = left-(int(speed)/3+5)*scaleFactor[1];//moves obstacle
    top-=obstacleImages[int(obstacles.get(i).get(2))].height*((obstacles.get(i).get(2)+scaleFactor[0])/2);//top
    if (left > pos[0]+character[0].width/2 && futureLeft < pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && top<bottomOfPlayer)  pos[0]-= (int(speed)/3+6)*scaleFactor[1];//checking if colliding 
    if(left < pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && bottomOfPlayer >= top && !onObstacle){//on top oof obstacle
      onObstacle = true;
      topOfObstacle = top;
      rightOfObstacle = right;
      pos[1] = topOfObstacle - (character[0].height/3+character[2].height);//player can stand on obstacle
      vy=0;
    }
    
  }
  rightOfObstacle -= (int(speed)/3+5)*scaleFactor[1];//finds the new position of right of obstacle
  if (rightOfObstacle <= pos[0]-character[0].width/2 || bottomOfPlayer != topOfObstacle && onObstacle) onObstacle = false;//checks if off obstacle
}


void initFont() {//initializing fonts
  for (int i = 0; i < regular.length; i++) {
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48*scaleFactor[0]);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48*scaleFactor[0]);
    xLight[i] = createFont("Font/Montserrat-ExtraLight.ttf", (i+1)*48*scaleFactor[0]);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48*scaleFactor[0]);
  }
}

void initImgs() {//adding all images and resizing to proper size
  armour = loadImage("Imgs/Armour.png");
  armour.resize(int(armour.width*3/4*scaleFactor[0]), int(armour.height*3/4*scaleFactor[0]));

  character[0] = loadImage("Imgs/Character Body.png");
  character[1] = loadImage("Imgs/Character Arm.png");
  character[2] = loadImage("Imgs/Character Leg.png");
  character[3] = loadImage("Imgs/Jetpack.png");
  character[4] = loadImage("Imgs/Fire.png");
  
  guns[0] = new PImage[2];
  guns[0][0] = loadImage("Imgs/Glock Shell.png");
  guns[0][1] = loadImage("Imgs/Glock Side.png");
  
  guns[1] = new PImage[2];
  guns[1][0] = loadImage("Imgs/Deagle Shell.png");
  guns[1][1] = loadImage("Imgs/Deagle Slide.png");
  
  for (int i = 2; i < guns.length; i++){
    guns[i] = new PImage[1];
    guns[i][0] = loadImage("Imgs/" + shopOptions[1][i] + ".png");
  }
  
  guns[2][0].resize(guns[2][0].width*3/4, guns[2][0].height*3/4);
  guns[3][0].resize(guns[3][0].width*3/4, guns[3][0].height*3/4);
  guns[5][0].resize(guns[5][0].width*3/4, guns[5][0].height*3/4);
  for (int i = 7; i <= 15; i++){
    guns[i][0].resize(guns[i][0].width*3/4, guns[i][0].height*3/4);
  }
  
  for (int i = 0; i < guns.length; i++){
    for (int j = 0; j < guns[i].length; j++){
      guns[i][j].resize(int(guns[i][j].width*scaleFactor[0]), int(guns[i][j].height*scaleFactor[0]));
    }
  }

  background[0] = loadImage("Imgs/Grass.png");
  background[1] = loadImage("Imgs/Clouds.png");
  background[2] = loadImage("Imgs/Blue Sky.png");
  background[0].resize(background[0].width, background[0].height*2/3);
  
  for(int i = 0; i < background.length; i++){
    background[i].resize(int(background[i].width*scaleFactor[1]), int(background[i].height*scaleFactor[1]));
  }
  
  bullet = loadImage("Imgs/Bullet.png");
  bullet.resize(int(bullet.width*5*scaleFactor[0]), int(bullet.height*5*scaleFactor[0]));
  
  rocket = loadImage("Imgs/RPG Ammo.png");
  rocket.resize(int(rocket.width*scaleFactor[0]), int(rocket.height*scaleFactor[0]));
  
  obstacleImages[0] = loadImage("Imgs/Tree.png");
  obstacleImages[1] = loadImage("Imgs/Bricks.png");
  
  obstacleImages[0].resize(int(obstacleImages[0].width*scaleFactor[0]), int(obstacleImages[0].height*scaleFactor[0]));
  obstacleImages[1].resize(int(obstacleImages[1].width*scaleFactor[0]), int(obstacleImages[1].height*scaleFactor[0]));
  
  robot[0] = loadImage("Imgs/Robot.png");
  robot[1] = loadImage("Imgs/Robot Arm.png");
  robot[2] = loadImage("Imgs/Robot Leg.png");
  
  for (int i = 0; i < 5; i++) {
    character[i].resize(int(character[i].width*3/4*scaleFactor[0]), int(character[i].height*3/4*scaleFactor[0]));
    if(i<3){
      robot[i].resize(int(robot[i].width*3/4*scaleFactor[0]), int(robot[i].height*3/4*scaleFactor[0]));
    }
  }
  
  character[1].resize(character[1].width*3/4, character[1].height*3/4);
  robot[1].resize(robot[1].width*3/4, robot[1].height*3/4);
  mainMenuPic = loadImage("Imgs/Main Menu Screen.png");
  mainMenuPic.resize(int(float(mainMenuPic.width)*scaleFactor[0]*(1280.0/1920)), int(float(mainMenuPic.height)*scaleFactor[0]*(1280.0/1920)));
  coin = loadImage("Imgs/Coin.png");
  coin.resize(int(coin.width*scaleFactor[0]), int(coin.height*scaleFactor[0]));
}

String[][] shopOptions = new String[4][];//create new 2D array of shop options
int[][] shopCosts = new int[2][];//2D array for costs

void setup() {
  size(800, 600);//initializing size
  scaling();
  initFont();//initializing fonts
  if (loadStrings("data/saveData/saveGame.txt") != null) {
    saveData = loadStrings("data/saveData/saveGame.txt");
  }
  frameRate(30);//initializing framerate
  for (int i = 0; i < shopOptions.length; i++){
    shopOptions[i] = loadStrings("data/gameData/shopOptions"+i+".txt");
    if (i < 2){
      String[] buffer = loadStrings("data/gameData/shopPrice"+i+".txt");
      int[] intBuffer = new int[buffer.length];
      for (int j = 0; j < buffer.length; j++){
        intBuffer[j]=int(buffer[j]);
      }
      shopCosts[i] = intBuffer;
    }
  }
  initImgs();
  pos[0]=width*(500.0/1280);
  groundPos[0][1] = 500.0*scaleFactor[0];
  groundPos[1][0] = background[0].width;
  groundPos[1][1] = random(-70*scaleFactor[0], 70*scaleFactor[0])+500.0*scaleFactor[0];
  speedBoost = gravity*float(int(saveData[7])/2);
  maxFuel = 100+((int(saveData[7])+1)/2)*50;
  maxHealth = 100 + int(saveData[2])*50;
  health=maxHealth;//health of player
  fuel=maxFuel;//fuel of player
}

boolean[] buttons = {false, false, false, false};//array for buttons
String[] buttonText = {"Play Game", "Shop", "Credits", "Exit"};//array for main menu options
boolean firstTime;//checks if player is new

void mainMenu() {//initializing main menu
  background(100);//initializing background
  imageMode(CENTER);//changing image mode
  image(mainMenuPic, width/2, height-mainMenuPic.height/2);//adding image
  fill(255);//initializing fill
  textFont(regular[1], 96*scaleFactor[0]);//initializing font
  textAlign(CENTER, CENTER);//adjusting text alignment
  text("ZapZpeed", width/2, 100*scaleFactor[0]);//title
  textFont(light[0], 48*scaleFactor[0]);//light font
  rectMode(CENTER);//adjusting rect mode
  for (int i = 0; i < 4; i++){
    if (mouseX >= width/2-150*scaleFactor[0] && mouseX <= width/2+150*scaleFactor[0] && mouseY >= height/2-60*scaleFactor[0]+i*100*scaleFactor[0] && mouseY <= height/2+20*scaleFactor[0]+i*100*scaleFactor[0]) buttons[i] = true;//checks if any of the buttons have been pressed
    else buttons[i] = false;
    if (buttons[i]){
      fill(0);
      if(clicked){
        currentScene = i+1;
        if(i == 0) bulletsRemaining = bullets[int(saveData[1])];
      }
    }
    else fill(255,170);
    rect(width/2, height/2-20*scaleFactor[0]+100*i*scaleFactor[0], 300*scaleFactor[0], 80*scaleFactor[0]);
    if(buttons[i]) fill(255);
    else fill(0);
    text(buttonText[i], width/2, height/2-25*scaleFactor[0]+100*i*scaleFactor[0]);
  }
  if (int(saveData[0]) == 0){
    firstTime = true;
  }
}

boolean justJumped = false;
boolean holding = false;

void keyPressed() {//checks if key was pressed
  if (keyCode == 87 && (onGround || onObstacle) && !justJumped && pos[0]>0 && !holding && currentScene == 1 && !firstTime) {//only jump if on ground
    vy=JUMPPOWER*scaleFactor[0];//jumping power
    onGround = false;
    justJumped = true;
    holding = true;
  }
}//end keyPressed

boolean clicked = false;

void mousePressed(){//checks if mouse was pressed
  clicked = true;
}

void mouseReleased(){//checks if mouse was released
  clicked = false;
}

void keyReleased() {//checks if key was released
  if (key == 'w'){
    justJumped = false;
    holding = false;
  }
}


float rotation = 0;//finds rotation of arms and legs
float vR = radians(8.5);//speed of rotation

float recoil = 0;
float vRecoil = 0;

void addTrail() {//adding trail

  ArrayList<Float> newTrail = new ArrayList<Float>();//list for new trail
  newTrail.add(pos[0]-20*scaleFactor[0]);//adds a new trail every 20 pixels
  newTrail.add(pos[1]);//adds a trail on the same y axis as player
  newTrail.add(rotation);
  newTrail.add(recoil);
  trail.add(newTrail);
}

void jetpack() {//adding jetpack
  boolean jetpackUse = false;//not using jetpack
  if (keyPressed && key==32 && fuel >= 0) {//checks if space key is pressed
    image(character[4], pos[0]-character[0].width/2-4*scaleFactor[0],pos[1]+8*scaleFactor[0]+character[3].height/2 + character[4].height/2);//image of the fire
    if (pos[1] > -character[0].height/2){
      vy=(-3.0*gravity-speedBoost)*scaleFactor[0];//player goes up
      onGround = false;
      onObstacle = false;
    }
    else vy = 0;//checks if its on the top of the screen and stops jetpack from flying higher
    jetpackUse = true;
  }
  else jetpackUse = false;
  if(jetpackUse && !onGround){
    fuel-=0.5;//using fuel
  }
  else if(fuel<maxFuel && vy>=0 && !jetpackUse && onGround){//checks if fuel tank isnt full
    fuel+=0.5;//regenarating fuel
  }
}

void updateTrail() {
  for (int i = 0; i < trail.size(); i++) {
    tint(255, (trail.get(i).get(0) / pos[0])*150);//adds transparency
    pushMatrix();
    translate(trail.get(i).get(0), trail.get(i).get(1)+character[0].height/3);
    rotate(trail.get(i).get(2));
    image(character[2], 0, character[2].height/2);
    rotate(-trail.get(i).get(2)*2);
    image(character[2], 0, character[2].height/2);
    popMatrix();
    image(character[0], trail.get(i).get(0), trail.get(i).get(1));
    if (trail.get(i).get(3)==0 || reloading) {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(trail.get(i).get(2));
      if (int(saveData[1]) <= 1){
        image(guns[int(saveData[1])][0], guns[int(saveData[1])][0].width/5, character[1].height);
        image(guns[int(saveData[1])][1], guns[int(saveData[1])][0].width/2+guns[int(saveData[1])][1].width/4, character[1].height-trail.get(i).get(3));
      }
      else if (int(saveData[1]) <= 3 || int(saveData[1]) == 8) image(guns[int(saveData[1])][0], 0, character[1].height);
      else if (int(saveData[1]) == 4) image(guns[4][0], 0, character[1].height+guns[4][0].height/6);
      else if (int(saveData[1]) == 5) image(guns[5][0], guns[5][0].width/5, guns[5][0].height/3 + character[1].height);
      else if (int(saveData[1]) == 6) image(guns[6][0], 0, character[1].height+guns[6][0].height/4);
      else if (int(saveData[1]) == 7) image(guns[7][0], guns[7][0].width/4, character[1].height-guns[7][0].width/6);
      else if (int(saveData[1]) <=14) image(guns[int(saveData[1])][0], 0, character[1].height-guns[int(saveData[1])][0].height/10);
      else{
        switch(int(saveData[1])){
          case 15:
            image(guns[15][0], guns[15][0].width/4, character[1].height+guns[15][0].height/5);
            break;
          case 16:
            image(guns[16][0], guns[16][0].width/6, character[1].height+guns[16][0].height/6);
            break;
          case 17:
            image(guns[17][0], guns[17][0].width/6, character[1].height+guns[17][0].height/10);
            break;
          case 18:
            image(guns[18][0], 0, character[1].height-guns[18][0].height/5);
            break;
          case 19:
            image(guns[19][0], guns[17][0].width/6, character[1].height-guns[19][0].height/5);
            break;
        }
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    }
    else {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(-PI/2);
      if (int(saveData[1]) <= 1){
        image(guns[int(saveData[1])][0], guns[int(saveData[1])][0].width/5, character[1].height);
        image(guns[int(saveData[1])][1], guns[int(saveData[1])][0].width/2+guns[int(saveData[1])][1].width/4, character[1].height-trail.get(i).get(3));
      }
      else if (int(saveData[1]) <= 3 || int(saveData[1]) == 8) image(guns[int(saveData[1])][0], 0, character[1].height);
      else if (int(saveData[1]) == 4) image(guns[4][0], 0, character[1].height+guns[4][0].height/6);
      else if (int(saveData[1]) == 5) image(guns[5][0], guns[5][0].width/5, guns[5][0].height/3 + character[1].height);
      else if (int(saveData[1]) == 6) image(guns[6][0], 0, character[1].height+guns[6][0].height/4);
      else if (int(saveData[1]) == 7) image(guns[7][0], guns[7][0].width/4, character[1].height-guns[7][0].width/6);
      else if (int(saveData[1]) <=14) image(guns[int(saveData[1])][0], 0, character[1].height-guns[int(saveData[1])][0].height/10);
      else{
        switch(int(saveData[1])){
          case 15:
            image(guns[15][0], guns[15][0].width/4, character[1].height+guns[15][0].height/5);
            break;
          case 16:
            image(guns[16][0], guns[16][0].width/6, character[1].height+guns[16][0].height/6);
            break;
          case 17:
            image(guns[17][0], guns[17][0].width/6, character[1].height+guns[17][0].height/10);
            break;
          case 18:
            image(guns[18][0], 0, character[1].height-guns[18][0].height/5);
            break;
          case 19:
            image(guns[19][0], guns[17][0].width/6, character[1].height-guns[19][0].height/5);
            break;
        }
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    }
    trail.get(i).set(0, trail.get(i).get(0)+(int(speed)/3-10)*scaleFactor[1]);
    if (trail.get(i).get(0)+character[0].width < 0 || trail.get(i).get(0)/pos[0]*150 < 10) {
      trail.remove(i);
      i--;
    }
  }
}

boolean justFired = false;
float reloadStart = 0;

ArrayList<ArrayList<Float>> bulletPos = new ArrayList<ArrayList<Float>>();//2D arraylist of bullets

void addBullet(){
  ArrayList<Float> newBullet = new ArrayList<Float>();
  newBullet.add(pos[0]+character[0].width/2);
  if (int(saveData[1]) < 16) newBullet.add(pos[1]-character[1].width/2);
  else if (int(saveData[1]) <= 17) newBullet.add(pos[1]-character[1].width/2-guns[int(saveData[1])][0].width/5);
  else newBullet.add(pos[1] - character[1].width/2);
  newBullet.add(0.0);
  bulletPos.add(newBullet);
}

void drawBullet(){//draws bullet
  imageMode(CENTER);
  for(int i = 0; i < bulletPos.size(); i++){
    if (int(saveData[1]) < 18) image(bullet, bulletPos.get(i).get(0), bulletPos.get(i).get(1));
    else image(rocket, bulletPos.get(i).get(0), bulletPos.get(i).get(1));
    bulletPos.get(i).set(0, bulletPos.get(i).get(0)+30*scaleFactor[1]);
    if (bulletPos.get(i).get(0)-bullet.width/2 > width || (bulletPos.get(i).get(0)+bullet.width/2>groundPos[nextGround][0] && bulletPos.get(i).get(1) > topOfNextGrass && groundPos[nextGround][0] > 0)) bulletPos.remove(i);
  }
  for (int i = 0; i < enemyBullets.size(); i++){
    if (int(saveData[1]) < 18) image(bullet, enemyBullets.get(i).get(0), enemyBullets.get(i).get(1));
    else image(rocket, enemyBullets.get(i).get(0), enemyBullets.get(i).get(1));
    enemyBullets.get(i).set(0, enemyBullets.get(i).get(0)-(int(speed)/3+40));
    if (enemyBullets.get(i).get(0)-bullet.width/2 < 0){
      enemyBullets.remove(i);
    }
    else if (enemyBullets.get(i).get(0) > pos[0]+character[0].width/2 && enemyBullets.get(i).get(0)-(int(speed)/3+40)*scaleFactor[1] <= pos[0]+character[0].width/2 && enemyBullets.get(i).get(1) > pos[1]-character[0].height/2 && enemyBullets.get(i).get(1) < pos[1]+character[0].height/3+character[2].height){
      enemyBullets.remove(i);
      health -= dmg[int(saveData[1])];
    }
  }
}
boolean reloading = false;
int lastShot = 0;

void drawArms() {//adding arms on player
  rectMode(CENTER);//changing rect mode
  pushMatrix();
  translate(pos[0], pos[1]);//attaching on character
  if (recoil < 0){//resets recoil variables
    recoil = 0;
    vRecoil = 0;
  }
  if (mousePressed && !justFired && bulletsRemaining > 0 && lastShot + fireRate[int(saveData[1])] <= millis()) {//checks if able to to fire and player clicked
    vRecoil = 2*scaleFactor[0];//sets recoil
    recoil=2*scaleFactor[0];
    lastShot = millis();//last shot current time
    if (auto[int(saveData[1])] == false) justFired = true;//checks if semi-automatic weapon
    bulletsRemaining--;//bullets minus 1
    if (bulletsRemaining == 0) reloadStart = millis();//relaod if no more bullets
    addBullet();
  } else if (!mousePressed && (recoil == 0 || int(saveData[1]) <=1)) {//if released
    justFired = false;
  }
  if (recoil >= 10*scaleFactor[0]) {
    vRecoil*=-1;
  }
  if ((recoil != 0) || (int(saveData[1]) >= 2 && ((mousePressed && auto[int(saveData[1])])) || (auto[int(saveData[1])] == false && justFired)) && pos[0] > 0 && !reloading) {
    recoil+=vRecoil;
    rotate(-PI/2);
  } else if(pos[0]>0) rotate(rotation);
  if (int(saveData[1]) <= 1){
    image(guns[int(saveData[1])][0], guns[int(saveData[1])][0].width/5, character[1].height);
    image(guns[int(saveData[1])][1], guns[int(saveData[1])][0].width/2+guns[int(saveData[1])][1].width/4, character[1].height-recoil);
  }
  else if (int(saveData[1]) <= 3 || int(saveData[1]) == 8) image(guns[int(saveData[1])][0], 0, character[1].height);
  else if (int(saveData[1]) == 4) image(guns[4][0], 0, character[1].height+guns[4][0].height/6);
  else if (int(saveData[1]) == 5) image(guns[5][0], guns[5][0].width/5, guns[5][0].height/3 + character[1].height);
  else if (int(saveData[1]) == 6) image(guns[6][0], 0, character[1].height+guns[6][0].height/4);
  else if (int(saveData[1]) == 7) image(guns[7][0], guns[7][0].width/4, character[1].height-guns[7][0].width/6);
  else if (int(saveData[1]) <=14) image(guns[int(saveData[1])][0], 0, character[1].height-guns[int(saveData[1])][0].height/10);
  else{
    switch(int(saveData[1])){
      case 15:
        image(guns[15][0], guns[15][0].width/4, character[1].height+guns[15][0].height/5);
        break;
      case 16:
        image(guns[16][0], guns[16][0].width/6, character[1].height+guns[16][0].height/6);
        break;
      case 17:
        image(guns[17][0], guns[17][0].width/6, character[1].height+guns[17][0].height/10);
        break;
      case 18:
        image(guns[18][0], 0, character[1].height-guns[18][0].height/5);
        break;
      case 19:
        image(guns[19][0], guns[17][0].width/6, character[1].height-guns[19][0].height/5);
        break;
    }
  }
  image(character[1], 0, character[1].height/2);
  rectMode(CENTER);
  popMatrix();
  if (bulletsRemaining == 0 && millis()-reloadStart >= reloadTime[int(saveData[1])]) {
    bulletsRemaining = bullets[int(saveData[1])];
    reloading = false;
  }
  else if (bulletsRemaining == 0){//checks if reload is needed
    reloading = true;
  }
}

void charInfo() {
  fill(0);//adding fill
  textFont(regular[0], 48*scaleFactor[0]);//font type and size
  textAlign(LEFT);//changing text align
  text("Bullets remaining: " + bulletsRemaining, 48*scaleFactor[0], 48*scaleFactor[0]);//show bullets remaining
  text(int(distTravelled)+" m", 100*scaleFactor[0], 100*scaleFactor[0]);//shows distance travelled
  textAlign(RIGHT);//changing text align
  text("Money: $" + String.format("%,d", int(saveData[3])), width-100*scaleFactor[0], 48*scaleFactor[0]);//shows money the player has
  rectMode(CENTER);//changing rect mode
  fill(0);//adding fill
  rect(width/2, 55*scaleFactor[0], 150*scaleFactor[0], 60*scaleFactor[0]);//outline for health and fuel
  fill(255, 0, 0);//adding fill
  rectMode(CORNER);//chaging rect mode
  rect(width/2-70*scaleFactor[0], 30*scaleFactor[0], 140*(health/maxHealth)*scaleFactor[0], 20*scaleFactor[0]);//displays health
  fill(0, 0, 255);//changing fill
  rect(width/2-70*scaleFactor[0], 60*scaleFactor[0], 140*(fuel/maxFuel)*scaleFactor[0], 20*scaleFactor[0]);//displays fuel
}

void drawChar() {//draws character
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= pos[0]-character[0].width*1.75 || trail.get(trail.size()-1).get(1) > pos[1]+character[0].height*1.75 || trail.get(trail.size()-1).get(1)+character[0].height*1.75 < pos[1]) addTrail();//checks if able to add trail
  imageMode(CENTER);//changing image mode
  updateTrail();//updating trail
  tint(255, 255);//adding tint
  fill(0, 255, 0);//adding fill
  if (pos[0] > 0) {//checks if rotation of arms are beyond a certain point
    if (rotation >= PI/4 || rotation <= -PI/4) vR*=-1;
    rotation+=vR;
  }
  pushMatrix();
  translate(pos[0], pos[1]+character[0].height/3);
  rotate(rotation);
  image(character[2], 0, character[2].height/2);
  rotate(-rotation*2);
  image(character[2], 0, character[2].height/2);
  popMatrix();
  image(character[3],pos[0]-character[0].width/2-4*scaleFactor[0],pos[1]+9*scaleFactor[0]);
  image(character[0], pos[0], pos[1]);
  if (int(saveData[2]) > 0) image(armour, pos[0], pos[1]+character[0].height/2-armour.height/2);
  drawArms();
}
float nextHeight;
int next;
float[] skyX = {0, 1280};
ArrayList<ArrayList<Float>> obstacles = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> enemies = new ArrayList<ArrayList<Float>>();
ArrayList<ArrayList<Float>> enemyBullets = new ArrayList<ArrayList<Float>>();

void updateEnemies(){
  imageMode(CENTER);
  for (int i = 0; i < enemies.size(); i++){
    int currentGroundEnemy=0;
    float bottomEnemy = enemies.get(i).get(1)+robot[0].height/3+robot[2].height;
    for(int j = 0; j < 2; j++){
      if (enemies.get(i).get(0)>= groundPos[j][0] && enemies.get(i).get(0)<= groundPos[j][0]+background[0].width) currentGroundEnemy = j;
    }
    int nextGroundEnemy = (currentGroundEnemy+1)%2;
    float topGroundEnemy = groundPos[currentGroundEnemy][1]+49*scaleFactor[0];
    float nextTopGroundEnemy = groundPos[nextGroundEnemy][1]+49*scaleFactor[0];
    enemies.get(i).set(1, topGroundEnemy-(robot[0].height/3+robot[2].height));
    image(robot[0],enemies.get(i).get(0), enemies.get(i).get(1));
    pushMatrix();
    translate(enemies.get(i).get(0)-robot[1].width, enemies.get(i).get(1));
    scale(-1, 1);
    rotate(-PI/2);
    if (int(saveData[1]) <= 1){
      image(guns[int(saveData[1])][0], guns[int(saveData[1])][0].width/5, 0);
      image(guns[int(saveData[1])][1], guns[int(saveData[1])][0].width/2+guns[int(saveData[1])][1].width/4, -enemies.get(i).get(4));
    }
    else if (int(saveData[1]) <= 3 || int(saveData[1]) == 8) image(guns[int(saveData[1])][0], 0, 0);
    else if (int(saveData[1]) == 4) image(guns[4][0], 0, guns[4][0].height/6);
    else if (int(saveData[1]) == 5) image(guns[5][0], guns[5][0].width/5, guns[5][0].height/3);
    else if (int(saveData[1]) == 6) image(guns[6][0], 0, guns[6][0].height/4);
    else if (int(saveData[1]) == 7) image(guns[7][0], guns[7][0].width/4, guns[7][0].width/6);
    else if (int(saveData[1]) <=14) image(guns[int(saveData[1])][0], 0, guns[int(saveData[1])][0].height/10);
    else{
      switch(int(saveData[1])){
        case 15:
          image(guns[15][0], guns[15][0].width/4, guns[15][0].height/5);
          break;
        case 16:
          image(guns[16][0], guns[16][0].width/6, guns[16][0].height/6);
          break;
        case 17:
          image(guns[17][0], guns[17][0].width/6, guns[17][0].height/10);
          break;
        case 18:
          image(guns[18][0], 0, guns[18][0].height/5);
          break;
        case 19:
          image(guns[19][0], guns[17][0].width/6, guns[19][0].height/5);
          break;
      }
    }
    popMatrix();
    if (millis()-enemies.get(i).get(2) >= robotReload[int(saveData[1])] && enemies.get(i).get(0) < width){
      ArrayList<Float> newBullet = new ArrayList<Float>();
      newBullet.add(enemies.get(i).get(0)-robot[1].height);
      if (int(saveData[1]) < 16)newBullet.add(enemies.get(i).get(1)-robot[1].width/6);
      else if (int(saveData[1]) <= 17)newBullet.add(enemies.get(i).get(1)-robot[1].width/6-guns[int(saveData[1])][0].width/5);
      else newBullet.add(enemies.get(i).get(1)-robot[1].width/6);
      enemyBullets.add(newBullet);
      enemies.get(i).set(4, 2.0);
      enemies.get(i).set(2, float(millis()));
    }
    if (enemies.get(i).get(4)!=0){
      enemies.get(i).set(4, enemies.get(i).get(4)-enemies.get(i).get(5));
    }
    if (enemies.get(i).get(4) >= 10 || enemies.get(i).get(4) <= 0){
      enemies.get(i).set(5, enemies.get(i).get(5)*-1);
    }
    image(robot[1], enemies.get(i).get(0)-robot[1].width/2, enemies.get(i).get(1));
    image(robot[2], enemies.get(i).get(0), enemies.get(i).get(1)+robot[0].height/3+robot[2].height/2);
    if (!(enemies.get(i).get(0)-(int(speed)/3+10)*scaleFactor[1]>groundPos[nextGroundEnemy][0] && enemies.get(i).get(0)-(int(speed)/3+10)*scaleFactor[1] < groundPos[nextGroundEnemy][0]+background[0].width && bottomEnemy-nextTopGroundEnemy>5)) enemies.get(i).set(0, enemies.get(i).get(0)-(int(speed)/3+10)*scaleFactor[1]);
    rectMode(CENTER);
    fill(0);
    rect(enemies.get(i).get(0), enemies.get(i).get(1)-robot[0].height/2 - 50*scaleFactor[0], 200*scaleFactor[0], 40*scaleFactor[0]);
    fill(255, 0, 0);
    rectMode(CORNER);
    rect(enemies.get(i).get(0)-90*scaleFactor[0], enemies.get(i).get(1)-robot[0].height/2 - 60 * scaleFactor[0], 180*(enemies.get(i).get(3)/100)*scaleFactor[0], 20*scaleFactor[0]);
    if (enemies.get(i).get(0)+robot[2].width/2 <= 0) enemies.remove(i);
  }
}

void drawUpdateObstacle(){
  imageMode(CENTER);
  for(int i = 0; i < obstacles.size(); i++){
    image(obstacleImages[int(obstacles.get(i).get(2))], obstacles.get(i).get(0), obstacles.get(i).get(1)-obstacleImages[int(obstacles.get(i).get(2))].height/2);
    obstacles.get(i).set(0, obstacles.get(i).get(0)-(int(speed)/3+5)*scaleFactor[1]);
    if (obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].height/2 <= 0){
      obstacles.remove(i);
      i--;
    }
  }
}
void detectCollision(){
  for(int i = 0; i < bulletPos.size(); i++){
    int[] value = {-1, -1};
    float closest = 1000000;
    float topOfClosest = 100000;
    float bottomOfClosest = 100000;
    float rightClosest = 1000000;
    for (int j = 0; j < obstacles.size(); j++){
      float top = obstacles.get(j).get(1) - obstacleImages[int(obstacles.get(j).get(2))].height;
      float left = obstacles.get(j).get(0) - obstacleImages[int(obstacles.get(j).get(2))].width/2;
      float right = obstacles.get(j).get(0) + obstacleImages[int(obstacles.get(j).get(2))].width/2;
      if (left < closest && right < rightClosest && bulletPos.get(i).get(0) < right && bulletPos.get(i).get(1) > top&& bulletPos.get(i).get(1)<obstacles.get(j).get(1)){
        closest = left;
        rightClosest = right;
        topOfClosest = top;
        bottomOfClosest = obstacles.get(j).get(1);
        value[0] = j;
        value[1] = 0;
      }
    }
    for (int j = 0; j < enemies.size(); j++){
      float bottom = enemies.get(j).get(1)+robot[0].height/3+robot[2].height;
      float top = enemies.get(j).get(1)-robot[0].height/2;
      float left = enemies.get(j).get(0)-robot[0].width/2;
      float right = enemies.get(j).get(0)+robot[0].width/2;
      if (left < closest && right < rightClosest && bulletPos.get(i).get(0) < right && bulletPos.get(i).get(1) > top && bulletPos.get(i).get(1) < bottom){
        closest = left;
        rightClosest = right;
        topOfClosest = top;
        bottomOfClosest = bottom;
        value[0] = j;
        value[1] = 1;
      }
    }
    if (closest <= bulletPos.get(i).get(0) && rightClosest <= bulletPos.get(i).get(0)  || closest <= pos[0]-character[0].width/2){
      closest = 100000;
      rightClosest = 100000;
    }
    if (bulletPos.get(i).get(0)+30*scaleFactor[0] >= closest && bulletPos.get(i).get(1) > topOfClosest && bulletPos.get(i).get(1) < bottomOfClosest){
      if (value[1] == 1){
        enemies.get(value[0]).set(3, enemies.get(value[0]).get(3)-dmg[int(saveData[1])]);
        if (enemies.get(value[0]).get(3) <= 0){
          enemies.remove(value[0]);
          value[0] = -1;
          value[1] = -1;
          closest = 100000;
          rightClosest = 100000;
          saveData[3] = Integer.toString(int(saveData[3])+int(random(0, 11))*100);
        }
      }
      else{
        obstacles.get(value[0]).set(3, obstacles.get(value[0]).get(3)-dmg[int(saveData[1])]);
        obstacles.get(value[0]).set(1, obstacles.get(value[0]).get(1)+obstacleImages[int(obstacles.get(value[0]).get(2))].height*(dmg[int(saveData[1])])/100);
        if (obstacles.get(value[0]).get(3) <= 0){
          obstacles.remove(value[0]);
          value[0] = -1;
          value[1] = -1;
          closest = 100000;
          rightClosest = 100000;
        }
      }
      if (int(saveData[1]) >= 18){
        for (int j = 0; j < enemies.size(); j++){
          float distToEnemy = dist(bulletPos.get(i).get(0), bulletPos.get(i).get(1), enemies.get(j).get(0), enemies.get(j).get(1));
          if (400*scaleFactor[1]/distToEnemy >= 1){
            enemies.remove(j);
            j--;
          }
        }
        for (int j = 0; j < obstacles.size(); j++){
          float distToObstacles = dist(bulletPos.get(i).get(0), bulletPos.get(i).get(1), obstacles.get(j).get(0), obstacles.get(j).get(1));
          if (400/distToObstacles >= 1){
            obstacles.remove(j);
            j--;
          }
        }
      }
      if ((int(saveData[1]) != 15 && int(saveData[1]) != 14) || (bulletPos.get(i).get(2) >= 3)) bulletPos.remove(i);
      else bulletPos.get(i).set(2, bulletPos.get(i).get(2)+1);
    }
  }
  for (int i = 0; i < enemies.size(); i++){
    float right = enemies.get(i).get(0)+robot[0].width/2;
    float futureLeft = enemies.get(i).get(0)-robot[0].width/2-(int(speed)/3+10);
    float top = enemies.get(i).get(1)-robot[0].height/2;
    float bottom = enemies.get(i).get(1) + robot[0].height/3+robot[2].height;
    float bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;
    float topOfPlayer = pos[1]-character[0].height/2;
    if (right > pos[0]-character[0].width/2 && futureLeft < pos[0]+character[0].width/2 && topOfPlayer < bottom && bottomOfPlayer > top){
      health -= enemies.get(i).get(3)/4;
      enemies.remove(i);
      
    }
  }
}

void updateCoins(){
  imageMode(CENTER);
  for (int i = 0; i < coins.size(); i++){
    image(coin, coins.get(i).get(0), coins.get(i).get(1));
    coins.get(i).set(0, coins.get(i).get(0)-(int(speed)/3+5)*scaleFactor[1]);
    if (coins.get(i).get(1)-25*scaleFactor[0]>pos[1]-character[0].height/2&& coins.get(i).get(0)<pos[0]+character[0].width/2 && coins.get(i).get(0) > pos[0]-character[0].width/2 && coins.get(i).get(1)-25 < pos[1]+character[0].height/3+character[2].height){
      coins.remove(i);
      i++;
      saveData[3] = Integer.toString(int(saveData[3])+int(random(5,11))*100);
    }
  }
}

void game() {
  imageMode(CENTER);
  image(background[2], width/2, height/2);
  nextHeight = random(-75*scaleFactor[0], 75*scaleFactor[0]);
  imageMode(CORNER);
  for (int i = 0; i < skyX.length; i++){
    image(background[1], skyX[i], 0);
    if (!firstTime) skyX[i]-=int(speed)/4+1;
    if (skyX[i] <= -background[1].width){
      if (i == 0) next = 1;
      else next = 0;
      if (skyX[next] < 0) skyX[i] = width;
      else skyX[i] = skyX[next]+background[1].width;
    }
  }
  drawBullet();
  drawUpdateObstacle();
  imageMode(CORNER);
  for (int i = 0; i < groundPos.length; i++) {
    if(pos[1]>groundPos[i][1]-100*scaleFactor[0] && pos[0]<groundPos[i][0]+305*scaleFactor[1] && pos[0]>groundPos[i][0]+295*scaleFactor[1]){
      colliding=true;
    }
    fill(0);
    image(background[0], groundPos[i][0], groundPos[i][1]);
    if (groundPos[i][0] <= -background[0].width) {
      if (i == 0) next = 1;
      else next = 0;
      if (groundPos[next][1]+nextHeight > height-50*scaleFactor[0]) {
        groundPos[i][1] = height-50*scaleFactor[0];
      }
      else if (groundPos[next][1]+nextHeight < height-400*scaleFactor[0]){
        groundPos[i][1] = height-400*scaleFactor[0];
      }
      else groundPos[i][1] = groundPos[next][1]+nextHeight;
      groundPos[i][0] = groundPos[next][0]+background[0].width;
      int randomNumber = int(random(0, 4));
      for (int a = 0; a < randomNumber; a++){
        ArrayList<Float> newObstacle = new ArrayList<Float>();
        float whatObstacle = int(random(0, 2));
        newObstacle.add(random(groundPos[i][0]+obstacleImages[0].width, groundPos[i][0]+background[0].width-obstacleImages[0].width));
        newObstacle.add(groundPos[i][1]+34*scaleFactor[1]);
        newObstacle.add(whatObstacle);
        newObstacle.add(100.0);
        obstacles.add(newObstacle);
      }
      int numOfEnemies = int(random(0, 4));
      for (int a = 0; a < numOfEnemies; a++){
        ArrayList<Float> newEnemy = new ArrayList<Float>();
        newEnemy.add(random(groundPos[i][0]+robot[2].width, groundPos[i][0]+background[0].width-robot[2].width));
        newEnemy.add(groundPos[i][1]+34*scaleFactor[1]);
        newEnemy.add(float(millis()));
        newEnemy.add(100.0);
        newEnemy.add(0.0);
        newEnemy.add(2.0);
        enemies.add(newEnemy);
      }
      int numOfCoins = int(random(0, 4));
      for (int a = 0; a < numOfCoins; a++){
        ArrayList<Float> newCoin = new ArrayList<Float>();
        newCoin.add(random(groundPos[i][0]+100*scaleFactor[0], groundPos[i][0]+background[0].width-100*scaleFactor[0]));
        newCoin.add(groundPos[i][1]+34*scaleFactor[1]-25*scaleFactor[0]);
        coins.add(newCoin);
      }
    }
    if (!firstTime) groundPos[i][0]-=(int(speed)/3+5)*scaleFactor[1];
  }
  updateCoins();
  updateEnemies();
  detectCollision();
  if (!firstTime){
    movePlayer();
    distTravelled=distTravelled+0.04*speed;
    speed=speed+speedUp/60;
    if(colliding){
      distTravelled=distTravelled-0.04*speed;
     }
    drawChar();
    jetpack();
  }
  else {
    rectMode(CENTER);
    fill(0, 200);
    rect(width/2, height/2, width*0.8, height*0.8);
    fill(255);
    textFont(regular[1], 70*scaleFactor[0]);
    textAlign(CENTER, CENTER);
    text("Rules to the game", width/2, height/2-height*0.4+100*scaleFactor[0]);
    textFont(light[0], 48*scaleFactor[0]);
    text("Press W to jump, Space to use jetpack,", width/2, height/2-80*scaleFactor[0]);
    text("and Left Click to shoot.", width/2, height/2-20*scaleFactor[0]);
    text("Go the furthest distance without dying!", width/2, height/2+40*scaleFactor[0]);
    text("Press anywhere to continue", width/2, height/2+150*scaleFactor[0]);
    if (clicked) firstTime = false;
  }
  if(pos[0]<=0 || health <= 0){
    speed=0;
    pos[0]=-1000;
    fill(0);
    textAlign(CENTER, CENTER);
    textFont(regular[1], 70*scaleFactor[0]);
    text("GAME OVER",width/2, height/2 - 120*scaleFactor[0]);
    text("Distance: "+int(distTravelled)+"m",width/2,height/2);
    int highscore = int(saveData[0]);
    if (int(distTravelled) > highscore) highscore = int(distTravelled);
    text("High score: " + highscore+"m", width/2, height/2+120*scaleFactor[0]);
    textFont(regular[0], 48*scaleFactor[0]);
    if (mouseX > width/2-300*scaleFactor[0] && mouseX < width/2 + 300*scaleFactor[0] && mouseY > height-130*scaleFactor[0] && mouseY < height-70*scaleFactor[0]){
      fill(127);
      if (clicked){
        currentScene = 0;
        pos[0] = width*(500.0/1280);
        pos[1] = 0;
        vy = 0;
        bulletsRemaining = 0;
        speed = 1;
        speedUp = 0.1;
        saveData[0] = Integer.toString(highscore);
        distTravelled = 0;
        obstacles.clear();
        reloading = false;
        health = maxHealth;
        fuel = maxFuel;
        enemies.clear();
        bulletPos.clear();
        enemyBullets.clear();
        coins.clear();
        saveStrings("data/saveData/saveGame.txt", saveData);
      }
    }
    else fill(255);
    rect(width/2, height-100*scaleFactor[0], 600*scaleFactor[0], 60*scaleFactor[0]);
    fill(0);
    text("Return to main menu", width/2, height-105*scaleFactor[0]);
    
  }
  else if (!firstTime) charInfo();
  if (justJumped) justJumped = false;
}

void credits() {
  background(100);
  imageMode(CENTER);
  image(mainMenuPic, width/2, height/2);
  textFont(regular[1], 96*scaleFactor[0]);
  textAlign(CENTER, CENTER);
  fill(255);
  text("Credits", width/2, 100*scaleFactor[0]);
  textFont(light[0], 48*scaleFactor[0]);
  text("Sprites made by: Gordon Lin", width/2, 200*scaleFactor[0]);
  text("Code made by: Gordon Lin and Daniel Weng", width/2, 280*scaleFactor[0]);
  text("Font made by: Montserrat Project Authors", width/2, 360*scaleFactor[0]);
  boolean mouseOver = mouseX >= width/2-450*scaleFactor[0] && mouseX <= width/2+450*scaleFactor[0] && mouseY >= 400*scaleFactor[0] && mouseY <= 480*scaleFactor[0];
  text("Press anywhere to return to main menu", width/2, height-100*scaleFactor[0]);
  rectMode(CENTER);
  if (mouseOver) fill(0);
  rect(width/2, 440*scaleFactor[0], 900*scaleFactor[0], 80*scaleFactor[0]);
  if (!mouseOver) fill(0);
  else fill(255);
  text("Click here to view license for font", width/2, 440*scaleFactor[0]);
  if (mouseOver && clicked) link("https://raw.githubusercontent.com/JulietaUla/Montserrat/master/OFL.txt");
  else if (clicked) currentScene = 0;
}

int[] selection = {int(saveData[1]), int(saveData[2]), int(saveData[6])};

void shop(){
  background(0);
  fill(255);
  textFont(regular[1], 96*scaleFactor[0]);
  textAlign(CENTER, CENTER);
  text("Shop",width/2, 70*scaleFactor[0]);
  rectMode(CENTER);
  textFont(regular[0], 30*scaleFactor[0]);
  textAlign(RIGHT, CENTER);
  text("Money: $" + String.format("%,d", int(saveData[3])), width-70*scaleFactor[0], 70*scaleFactor[0]);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < shopOptions[0].length; i++){
    textFont(light[0], 40*scaleFactor[0]);
    fill(255);
    text(shopOptions[0][i], width/2, i*170*scaleFactor[0] + 180*scaleFactor[0]);
    textFont(light[0], 30*scaleFactor[0]);
    if (i!=2){
      String price;
      if (selection[i] > int(saveData[i+4])+1) price = "LOCKED";
      else if (selection[i] > int(saveData[i+4]))price = "$" + String.format("%,d", shopCosts[i][selection[i]]);
      else if (selection[i] == int(saveData[i+1]))price = "SELECTED";
      else price = "BOUGHT";
      text(shopOptions[i+1][selection[i]] + " (" + price + ")", width/2, i*170*scaleFactor[0]+310*scaleFactor[0]);
      if (mouseX >= width/2-40*scaleFactor[0] && mouseX <= width/2+40*scaleFactor[0] && mouseY >= i*170*scaleFactor[0]+210*scaleFactor[0] && mouseY <= i*170*scaleFactor[0]+290*scaleFactor[0]){
        fill(127);
        if (clicked){
          if (selection[i] <= int(saveData[i+4]) || (int(saveData[3]) >= shopCosts[i][selection[i]] && selection[i] == int(saveData[i+4])+1)){
            saveData[i+1] = Integer.toString(selection[i]);
            maxHealth = 100 + int(saveData[2])*50;
            health = maxHealth;
          }
          if (int(saveData[3]) >= shopCosts[i][selection[i]] && selection[i] == int(saveData[i+4])+1){
            saveData[3] = Integer.toString(int(saveData[3]) - shopCosts[i][selection[i]]);
            saveData[i+4] = Integer.toString(int(saveData[i+4])+1);
          }
          saveStrings("data/saveData/saveGame.txt", saveData);
        }
      }
      else fill(255);
      rect(width/2, i*170*scaleFactor[0]+250*scaleFactor[0], 80*scaleFactor[0], 80*scaleFactor[0]);
      imageMode(CENTER);
      switch(i){
        case 0:
          pushMatrix();
          translate(width/2, i*170*scaleFactor[0]+250*scaleFactor[0]);
          rotate(-PI/2);
          switch(selection[0]){
            case 0:
              image(guns[0][0], 0, 0);
              image(guns[0][1], guns[0][0].width/2-guns[0][1].width/2-scaleFactor[0], 0);
              break;
            case 1:
              image(guns[1][0], 0, 0);
              image(guns[1][1], guns[1][0].width/2-guns[1][1].width/2-1, -1);
              break;
            default:
              scale(75.0*scaleFactor[0]/guns[selection[0]][0].height);
              image(guns[selection[0]][0], 0, 0);
              break;
          }
          popMatrix();
          break;
      }
      float[] areas = {abs(((width/2-50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY) - ((width/2-50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY)), abs(((width/2-50*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY) - ((width/2-90*scaleFactor[0]) - mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY)), abs(((width/2-90*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY) - ((width/2-50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY))};
      if (areas[0]  + areas[1] + areas[2]== abs(((width/2-50*scaleFactor[0])-(width/2-50*scaleFactor[0]))*((i*170*scaleFactor[0]+250*scaleFactor[0])-(i*170*scaleFactor[0]+210*scaleFactor[0])) - ((width/2-90*scaleFactor[0])-(width/2-50*scaleFactor[0]))*((i*170*scaleFactor[0]+290*scaleFactor[0]) - (i*170*scaleFactor[0]+210*scaleFactor[0])))){
        fill(127);
        if (clicked && selection[i] > 0) selection[i]--;
      }
      else fill (255);
      beginShape();
      vertex(width/2-50*scaleFactor[0], i*170*scaleFactor[0]+210*scaleFactor[0]);
      vertex(width/2-50*scaleFactor[0], i*170*scaleFactor[0]+290*scaleFactor[0]);
      vertex(width/2-90*scaleFactor[0], i*170*scaleFactor[0]+250*scaleFactor[0]);
      endShape();
      float[] areas1 = {abs(((width/2+50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY) - ((width/2+50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY)), abs(((width/2+50*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY) - ((width/2+90*scaleFactor[0]) - mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY)), abs(((width/2+90*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY) - ((width/2+50*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY))};
      if (areas1[0]  + areas1[1] + areas1[2]== abs(((width/2+50*scaleFactor[0])-(width/2+50*scaleFactor[0]))*((i*170*scaleFactor[0]+250*scaleFactor[0])-(i*170*scaleFactor[0]+210*scaleFactor[0])) - ((width/2+90*scaleFactor[0])-(width/2+50*scaleFactor[0]))*((i*170*scaleFactor[0]+290*scaleFactor[0]) - (i*170*scaleFactor[0]+210*scaleFactor[0])))){
        fill(127);
        if (clicked && (selection[i] < shopOptions[i+1].length-1)||(i == 2 && selection[i]<int(saveData[6]))) selection[i]++;
      }
      else fill (255);
      beginShape();
      vertex(width/2+50*scaleFactor[0], i*170*scaleFactor[0]+210*scaleFactor[0]);
      vertex(width/2+50*scaleFactor[0], i*170*scaleFactor[0]+290*scaleFactor[0]);
      vertex(width/2+90*scaleFactor[0], i*170*scaleFactor[0]+250*scaleFactor[0]);
      endShape();
    }
    else{
      textAlign(CENTER);
      if (mouseX >= width/2-150*scaleFactor[0] && mouseX <= width/2+150*scaleFactor[0] && mouseY >= i*170*scaleFactor[0]+210*scaleFactor[0] && mouseY <= i*170*scaleFactor[0]+290*scaleFactor[0]){
        fill(127);
        if (clicked){
          if (selection[i] <= int(saveData[i+4]) || int(saveData[3]) >= selection[2]*5000){
            saveData[7] = Integer.toString(selection[i]);
            maxFuel = 100+((int(saveData[7])+1)/2)*50;
            speedBoost = gravity*(int(saveData[7])/2.0);
            fuel = maxFuel;
          }
          if (int(saveData[3]) >= selection[2]*5000 && selection[i] > int(saveData[i+4])){
            saveData[3] = Integer.toString(int(saveData[3]) - 5000*selection[2]);
            saveData[i+4] = Integer.toString(int(saveData[i+4])+1);
          }
          saveStrings("data/saveData/saveGame.txt", saveData);
        }
      }
      else fill(255);
      rect(width/2, i*170*scaleFactor[0]+250*scaleFactor[0], 300*scaleFactor[0], 80*scaleFactor[0]);
      fill(0);
      if (selection[2] == 0){
        text("Stock", width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
      }
      else{
        if (selection[2]%2 == 1) text(shopOptions[i+1][selection[2]%2] + ((selection[2]+1)/2), width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
        else text(shopOptions[i+1][selection[2]%2] + (selection[2]/2), width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
      }
      if (selection[2] == int(saveData[7]) )text("(SELECTED)", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      else if (selection[2] > int(saveData[i+4])) text("($" + String.format("%,d", selection[2]*5000) + ")", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      else text("(BOUGHT)", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      float[] areas = {abs(((width/2-160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY) - ((width/2-160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY)), abs(((width/2-160*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY) - ((width/2-200*scaleFactor[0]) - mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY)), abs(((width/2-200*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY) - ((width/2-160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY))};
      if (areas[0]  + areas[1] + areas[2]== abs(((width/2-160*scaleFactor[0])-(width/2-160*scaleFactor[0]))*((i*170*scaleFactor[0]+250*scaleFactor[0])-(i*170*scaleFactor[0]+210*scaleFactor[0])) - ((width/2-200*scaleFactor[0])-(width/2-160*scaleFactor[0]))*((i*170*scaleFactor[0]+290*scaleFactor[0]) - (i*170*scaleFactor[0]+210*scaleFactor[0])))){
        fill(127);
        if (clicked && selection[i] > 0) selection[i]--;
      }
      else fill (255);
      beginShape();
      vertex(width/2-160*scaleFactor[0], i*170*scaleFactor[0]+210*scaleFactor[0]);
      vertex(width/2-160*scaleFactor[0], i*170*scaleFactor[0]+290*scaleFactor[0]);
      vertex(width/2-200*scaleFactor[0], i*170*scaleFactor[0]+250*scaleFactor[0]);
      endShape();
      float[] areas1 = {abs(((width/2+160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY) - ((width/2+160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY)), abs(((width/2+160*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY) - ((width/2+200*scaleFactor[0]) - mouseX) * ((i*170*scaleFactor[0]+290*scaleFactor[0])-mouseY)), abs(((width/2+200*scaleFactor[0])-mouseX)*((i*170*scaleFactor[0]+210*scaleFactor[0])-mouseY) - ((width/2+160*scaleFactor[0])-mouseX) * ((i*170*scaleFactor[0]+250*scaleFactor[0])-mouseY))};
      if (areas1[0]  + areas1[1] + areas1[2]== abs(((width/2+160*scaleFactor[0])-(width/2+160*scaleFactor[0]))*((i*170*scaleFactor[0]+250*scaleFactor[0])-(i*170*scaleFactor[0]+210*scaleFactor[0])) - ((width/2+200*scaleFactor[0])-(width/2+160*scaleFactor[0]))*((i*170*scaleFactor[0]+290*scaleFactor[0]) - (i*170*scaleFactor[0]+210*scaleFactor[0])))){
        fill(127);
        if (clicked && selection[i] <= int(saveData[i+4]))selection[i]++;
      }
      else fill (255);
      beginShape();
      vertex(width/2+160*scaleFactor[0], i*170*scaleFactor[0]+210*scaleFactor[0]);
      vertex(width/2+160*scaleFactor[0], i*170*scaleFactor[0]+290*scaleFactor[0]);
      vertex(width/2+200*scaleFactor[0], i*170*scaleFactor[0]+250*scaleFactor[0]);
      endShape();
    }
  }
  if(mouseX>=width/2-175*scaleFactor[0] && mouseX <= width/2+175*scaleFactor[0] && mouseY >= height-75*scaleFactor[0] && mouseY <= height-25*scaleFactor[0]){
    fill(127);
    if(clicked) currentScene = 0;
  }
  else fill(255);
  rect(width/2, height-50*scaleFactor[0], 350*scaleFactor[0], 50*scaleFactor[0]);
  fill(0);
  text("Return to main menu", width/2, height-40*scaleFactor[0]);
}

void draw() {
  if (currentScene == 0) mainMenu();
  else if (currentScene == 2) shop();
  else if (currentScene == 3) credits();
  else if (currentScene == 1) game();
  else if (currentScene == 4) exit();
  if (clicked) clicked = false;
}
