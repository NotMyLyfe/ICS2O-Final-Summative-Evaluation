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
PImage icon;

int[] reloadTime = {1500, 2500, 2750, 2000, 3500, 3500, 4250, 3500, 3250, 3000, 2750, 2750, 2250, 2500, 4500, 4600, 6000, 6250, 10000, 10000};//shows reload time for all guns
boolean[] auto = {false, false, true, true, false, false, true, true, false, true, true, true, true, true, false, false, true, true, false, false}; //if guns are either auto or semi-auto

//initializing gravity
int JUMPPOWER=-12;
float gravity=0.6;
boolean jump=false;

//position of player
float pos[] = {500.0, 0.0};

float vy=0;//vertical speed

int[] fireRate = {50, 50, 250, 250, 100, 100, 250, 150, 100, 100, 100, 100, 50, 100, 50, 50, 100, 100, 50, 50}; //fire rate of each gun
int[] bullets = {12, 7, 25, 32, 8, 8, 32, 50, 30, 30, 30, 30, 30, 30, 1, 10, 150, 150, 1, 1};//bullet capacity
int[] dmg = {25, 40, 30, 25, 50, 55, 40, 35, 35, 40, 35, 40, 40, 50, 200, 250, 30, 40, 1000, 2000};//bullet damage
int[] robotReload = {1250, 1500, 750, 750, 1000, 1000, 750, 750, 750, 750, 750, 750, 750, 750, 4500, 1000, 750, 750, 10000, 10000};//shows reload time for robots
int bulletsRemaining = 0;//bullets remaining

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();//2D list for trail

float distTravelled=0;//current distance travelled
float speed=1;//current speed
float speedUp=0.1;//increasing speed

PImage background[] = new PImage[3];//background image

float[][] groundPos = {{0, 0}, {0, 0}};//shows ground position
float[] skyX = {0, 0}; //position for sky

//initializing information about ground
float topOfGrass = 0;
float topOfNextGrass = 0;
int nextGround = 0;
int current = 0;
float bottomOfPlayer = 0;
boolean onGround = true;
boolean colliding = false;
boolean gap = false;

float speedBoost; //value of the jetpack speed boost
float maxFuel; //value of the maximum fuel of jetpack
float maxHealth; //value of maximum health
float health; //health of player
float fuel; //fuel of player
ArrayList<ArrayList<Float>> coins = new ArrayList<ArrayList<Float>>();//2D list for coins

boolean onObstacle = false;//on or off obstacle
float topOfObstacle = 0; //finds top of obstacle
float rightOfObstacle = 0; //find the right of obstacle

//array for scaling
float[] scaleFactor = {1, 1, 1, 1}; //0-main scaling factor, 1-scale for background and sky, 2-x scale, 3-y scale

void scaling(){ //find scale factors
  scaleFactor[2] = float(width)/1280.0; //scaling on x axis
  scaleFactor[3] = float(height)/720.0; //scaling on y axis
  
  //determining main scaling factors
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
  nextGround = (current+1)%2; //finds the next ground position
  topOfGrass = groundPos[current][1]+(49*scaleFactor[1]); //finds the top of the grass that the player is currently on
  topOfNextGrass = groundPos[nextGround][1]+(49*scaleFactor[1]); //finds the top of the grass that the player will go on
  if (onGround) pos[1]=topOfGrass-(character[0].height/3+character[2].height); //determines if the player is on the ground, and puts player in right place
  else if (onObstacle) pos[1] = topOfObstacle - (character[0].height/3+character[2].height); //determines if the player is on an obstacle, and puts player above the obstacle
  else vy+=gravity*scaleFactor[0]; //determines if the player is not on an obstacle or ground, and adds gravity to the vertical speed
  if (groundPos[nextGround][0]-int((int(speed)/3+5)*scaleFactor[1])*2 <= pos[0]+character[0].width/2 && bottomOfPlayer-topOfNextGrass >= 10*scaleFactor[1] && groundPos[nextGround][0] > 0){ //checks if the player is going to collide with the ground
    pos[0]-= int((int(speed)/3+6)*scaleFactor[1])*2; //pushes the player back
    colliding = true; //sets collision to true
  }
  else{
    colliding = false; //sets collision to false
  }
  if (pos[0] < int(width*(500.0/1280)) && pos[0]>0){ //finds if the player was pushed back
    pos[0]+= scaleFactor[1]/2;//run back to original position
  }
  if (!onGround && bottomOfPlayer >= topOfGrass && !justJumped){//checking if on ground and falling
    vy = 0; //sets vertical speed to 0
    onGround = true; //sets onGround to true
  }
  for (int i = 0; i < obstacles.size(); i++){ //goes through every obstacle to detect collisions
    float top = obstacles.get(i).get(1) - obstacleImages[int(obstacles.get(i).get(2))].height*((obstacles.get(i).get(2)+1)/2);//
    float left = obstacles.get(i).get(0)-obstacleImages[int(obstacles.get(i).get(2))].width/3;//left of obstacle
    float right = obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].width/3;//right of obstacle
    float futureLeft = left-int((int(speed)/3+5)*scaleFactor[1])*2;
    
    //checks if the obstacle will collide with the player, and push the character back
    if (left > pos[0]+character[0].width/2 && futureLeft <= pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && (top < bottomOfPlayer || pos[1] > top || pos[1]-character[0].height/2 > top)){
      pos[0] -= int((int(speed)/3+6)*scaleFactor[1])*3;
    }
    else if (left < pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && (pos[1] > top || pos[1]-character[0].height/2 > top)){
      pos[0] -= int((int(speed)/3+6)*scaleFactor[1])*3;
    }
    else if(left < pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && bottomOfPlayer > top && pos[1] < top && pos[1]-character[0].height/2 < top && !onObstacle){//on top oof obstacle
      onObstacle = true; //sets onObstacle to true
      topOfObstacle = top; //sets the current topOfObstacle to the top of the current obstacle
      rightOfObstacle = right; //sets the current rightOfObstacle to the right of the current obstacle
      pos[1] = topOfObstacle - (character[0].height/3+character[2].height);//player can stand on obstacle
      vy=0; //sets vertical speed to 0
    }
  }
  rightOfObstacle -= int((int(speed)/3+5)*scaleFactor[1])*2;//finds the new position of right of obstacle
  if (rightOfObstacle <= pos[0]-character[0].width/2 || bottomOfPlayer != topOfObstacle && onObstacle) onObstacle = false;//checks if off obstacle and sets onObstacle to false
}


void initFont() {//initializing all fonts
  for (int i = 0; i < regular.length; i++) {
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48*scaleFactor[0]);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48*scaleFactor[0]);
    xLight[i] = createFont("Font/Montserrat-ExtraLight.ttf", (i+1)*48*scaleFactor[0]);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48*scaleFactor[0]);
  }
}

void initImgs() {//adding all images and resizing to proper size and scaled to the screen size
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
  fullScreen();//initializing size
  scaling(); //finds the scaling size
  initFont();//initializing fonts
  frame.setIconImage(java.awt.Toolkit.getDefaultToolkit().getImage("Imgs/Icon.png"));
  if (loadStrings("data/saveData/saveGame.txt") != null) { //checks if saveGame file exists
    saveData = loadStrings("data/saveData/saveGame.txt"); //loads saveGame file
  }
  frameRate(30);//initializing framerate
  for (int i = 0; i < shopOptions.length; i++){
    shopOptions[i] = loadStrings("data/gameData/shopOptions"+i+".txt"); //loads all shop options
    if (i < 2){ //checks if i is less than 2
      String[] buffer = loadStrings("data/gameData/shopPrice"+i+".txt"); //loads all prices of shop options, in a buffered string array
      int[] intBuffer = new int[buffer.length]; //intializes a new int array
      for (int j = 0; j < buffer.length; j++){
        intBuffer[j]=int(buffer[j]); //converts string to int
      }
      shopCosts[i] = intBuffer; //stores store prices
    }
  }
  initImgs(); //intializes all the pictures
  pos[0]=int(width*(500.0/1280)); //sets the position of player according the scaling of screen
  groundPos[0][1] = int(500.0*scaleFactor[0]); //sets vertical ground position of one grounds
  groundPos[1][0] = int(background[0].width); //sets the 2nd ground position to the length of the ground picture
  groundPos[1][1] = random(-70*scaleFactor[0], 70*scaleFactor[0])+500.0*scaleFactor[0]; //sets the vertical height of the 2nd ground position
  skyX[1] = width;
  speedBoost = gravity*float(int(saveData[7])/2); //finds the speedboost for jetpack
  maxFuel = 100+((int(saveData[7])+1)/2)*20;
  maxHealth = 100 + int(saveData[2])*20;
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
    else buttons[i] = false; //checks if mouse is not over button and sets button to false
    if (buttons[i]){ //checks if mouse is over button
      fill(0); //sets the button to black
      if(clicked){ //checks if button is clicked
        currentScene = i+1; //sets scene to corresponding button
        if(i == 0) bulletsRemaining = bullets[int(saveData[1])]; //sets bullets remaining to the current weapon
      }
    }
    else fill(255,170); //sets the button to translucent
    rect(width/2, height/2-20*scaleFactor[0]+100*i*scaleFactor[0], 300*scaleFactor[0], 80*scaleFactor[0]); //add buttons
    if(buttons[i]) fill(255); //checks if mouse is over button and sets text to white
    else fill(0); //else sets text to black
    text(buttonText[i], width/2, height/2-25*scaleFactor[0]+100*i*scaleFactor[0]); //adds text of each button
  }
  if (int(saveData[0]) == 0){ //checks if the distance travelled is 0
    firstTime = true; //sets firstTime to true
  }
}

boolean justJumped = false; //checks if just jumped
boolean holding = false; // checks if still holding w button

void keyPressed() {//checks if key was pressed
  if (keyCode == 87 && (onGround || onObstacle) && !justJumped && pos[0]>0 && !holding && currentScene == 1 && !firstTime) {//only jump if on ground
    vy=int(JUMPPOWER*scaleFactor[3]);//jumping power
    onGround = false; //sets onGround to false
    justJumped = true; //sets justJumped to true
    holding = true; //sets holding to true
  }
}//end keyPressed

boolean clicked = false; //creates new boolean clicked, and sets false

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
float vR = radians(12);//speed of rotation

float recoil = 0; 
float vRecoil = 0;

void addTrail() {//adding trail

  ArrayList<Float> newTrail = new ArrayList<Float>();//list for new trail
  newTrail.add(pos[0]-20*scaleFactor[0]);//adds a new trail every 20 pixels
  newTrail.add(pos[1]);//adds a trail on the same y axis as player
  newTrail.add(rotation); //adds rotation of the arms and legs 
  newTrail.add(recoil); //adds recoil of weapon
  trail.add(newTrail); //adds newTrail to trail array
}

void jetpack() {//adding jetpack
  boolean jetpackUse = false;//not using jetpack
  if (keyPressed && key==32 && fuel >= 0) {//checks if space key is pressed
    image(character[4], pos[0]-character[0].width/2-4*scaleFactor[0],pos[1]+8*scaleFactor[0]+character[3].height/2 + character[4].height/2);//image of the fire
    if (pos[1] > -character[0].height/2){ //checks if weapon is lower than the top of the screen
      vy=(-3.0*gravity-speedBoost)*scaleFactor[0];//player goes up
      onGround = false; //sets onGround to false
      onObstacle = false; //sets onObstacle to false
    }
    else vy = 0;//checks if its on the top of the screen and stops jetpack from flying higher
    jetpackUse = true; //sets using jetpack to true
  }
  else jetpackUse = false; //sets using jetpakc to false is space key isn't pressed
  if(jetpackUse && !onGround){ //checks if jetpack is being used and not on ground
    fuel--;//subtracts 1 from fuel
  }
  else if(fuel<maxFuel && vy>=0 && !jetpackUse && onGround){//checks if fuel tank isnt full and onGround
    fuel++;//regenarating fuel
  }
}

void updateTrail() { //updates trail and draws trail
  for (int i = 0; i < trail.size(); i++) { //goes through the size of all the trails in trails list
    tint(255, (trail.get(i).get(0) / pos[0])*150);//adds transparency
    pushMatrix(); //begining of trail transformation
    translate(trail.get(i).get(0), trail.get(i).get(1)+character[0].height/3); //moves 0,0 to position
    rotate(trail.get(i).get(2)); //rotates images to angle
    image(character[2], 0, character[2].height/2); //shows legs
    rotate(-trail.get(i).get(2)*2); //rotates perpindicular to angle
    image(character[2], 0, character[2].height/2); //shows other leg
    popMatrix(); //ends of trail transformation
    image(character[0], trail.get(i).get(0), trail.get(i).get(1)); //shows body trail
    pushMatrix(); //begining of trail transformation
    translate(trail.get(i).get(0), trail.get(i).get(1)); //moves 0,0 to position
    if (trail.get(i).get(3)==0 || reloading) rotate(trail.get(i).get(2)); // rotates image to angle if image was not shot or reloading
    else rotate(-PI/2); //roates trailed image to perpindicular to body if gun was shot
    
    //draws trails of selected gun
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
    image(character[1], 0, character[1].height/2); //draws arm trail
    popMatrix(); //ending of trail transformation
    trail.get(i).set(0, trail.get(i).get(0)+int((int(speed)/3-10)*scaleFactor[1])*2); //moves trails back a bit
    if (trail.get(i).get(0)+character[0].width < 0 || trail.get(i).get(0)/pos[0]*150 < 10) { //checks if trail is almost transparent or trail is beyond the screen
      trail.remove(i); //removes trail
      i--; //moves i back one in order to properly update every trail
    }
  }
}

boolean justFired = false; // creates boolean to check if gun was fired
float reloadStart = 0; // float of when did it start reloading

ArrayList<ArrayList<Float>> bulletPos = new ArrayList<ArrayList<Float>>();//2D arraylist of bullets

void addBullet(){ //function to add bullets
  ArrayList<Float> newBullet = new ArrayList<Float>(); //create new list on new bullet
  newBullet.add(pos[0]+character[0].width/2); //adds bullet x position
  //adds bullet y position corresponding to the specific gun
  if (int(saveData[1]) < 16) newBullet.add(pos[1]-character[1].width/2);
  else if (int(saveData[1]) <= 17) newBullet.add(pos[1]-character[1].width/2-guns[int(saveData[1])][0].width/5);
  else newBullet.add(pos[1] - character[1].width/2);
  newBullet.add(0.0); //adds variable to determine how many objects sniper rifle has gone through
  bulletPos.add(newBullet); //adds newBullet to bulletPos
}

void drawBullet(){//draws bullets
  imageMode(CENTER); //aligns the images to center of image
  for(int i = 0; i < bulletPos.size(); i++){ //loop goes through every bullet in bulletPos
    if (int(saveData[1]) < 18) image(bullet, bulletPos.get(i).get(0), bulletPos.get(i).get(1)); //checks if gun isn't an rpg, and shows a bullet
    else image(rocket, bulletPos.get(i).get(0), bulletPos.get(i).get(1)); //else shows a rocket
    bulletPos.get(i).set(0, bulletPos.get(i).get(0)+60*scaleFactor[1]); //moves bullet
    if (bulletPos.get(i).get(0)-bullet.width/2 > width || (bulletPos.get(i).get(0)+bullet.width/2>groundPos[nextGround][0] && bulletPos.get(i).get(1) > topOfNextGrass && groundPos[nextGround][0] > 0)) bulletPos.remove(i); //checks if bullet hits ground or beyond screen
  }
  for (int i = 0; i < enemyBullets.size(); i++){ //llops goes through every bullet in enemyBullets
    if (int(saveData[1]) < 18) image(bullet, enemyBullets.get(i).get(0), enemyBullets.get(i).get(1)); //checks if gun isn't an rpg, and shows a bullet
    else image(rocket, enemyBullets.get(i).get(0), enemyBullets.get(i).get(1)); //else shows a rocket
    enemyBullets.get(i).set(0, enemyBullets.get(i).get(0)-int((int(speed)/3+40)*scaleFactor[1])*2); //moves bullet
    if (enemyBullets.get(i).get(0)-bullet.width/2 < 0){ //check if bullet goes beyond screen
      enemyBullets.remove(i); //removes bullet
    }
    else if (enemyBullets.get(i).get(0) > pos[0]+character[0].width/2 && enemyBullets.get(i).get(0)-int((int(speed)/3+40)*scaleFactor[1])*2 <= pos[0]+character[0].width/2 && enemyBullets.get(i).get(1) > pos[1]-character[0].height/2 && enemyBullets.get(i).get(1) < pos[1]+character[0].height/3+character[2].height){ //checks if bullet will hit player
      enemyBullets.remove(i); //removes bullet
      health -= dmg[int(saveData[1])]; //decrease health of player
    }
  }
}
boolean reloading = false; //boolean for reloading
int lastShot = 0; //time for when did it last shoot

void drawArms() {//adding arms on player
  rectMode(CENTER);//changing rect mode
  pushMatrix(); //begins image transformation
  translate(pos[0], pos[1]);//attaching on character
  if (recoil < 0){//resets recoil variables
    recoil = 0;
    vRecoil = 0;
  }
  if (mousePressed && !justFired && bulletsRemaining > 0 && lastShot + fireRate[int(saveData[1])] <= millis()) {//checks if able to to fire and player clicked
    vRecoil = 2*scaleFactor[0];//sets recoil
    recoil=2*scaleFactor[0];
    lastShot = millis();//last shot current time
    if (!auto[int(saveData[1])]) justFired = true;//checks if semi-automatic weapon
    bulletsRemaining--;//removes one from bulletsRemaining
    if (bulletsRemaining == 0) reloadStart = millis();//relaod if no more bullets
    addBullet(); //calls addBullet function
  } else if (!mousePressed && !auto[int(saveData[1])]) {//checks if mouse is released and is semi auto
    justFired = false; //sets justFired to false
  }
  if (recoil >= 10*scaleFactor[0]) { //checks if recoil is greater or equal to 10
    vRecoil*=-1; //sets speed of recoil to inverse
  }
  if ((recoil != 0) || (int(saveData[1]) >= 2 && ((mousePressed && auto[int(saveData[1])])) || (auto[int(saveData[1])] == false && justFired)) && pos[0] > 0 && !reloading) { //checks if gun was just shot or recoil is not 0 and character is on screen
    recoil+=vRecoil; //adds recoil speed to recoil
    rotate(-PI/2); //rotates arm perpindicular to player
  } else if(pos[0]>0) rotate(rotation); // else rotate to arm swing
  
  //draw guns
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
  
  image(character[1], 0, character[1].height/2); //draw arms
  popMatrix();//ends transformation
  if (bulletsRemaining == 0 && millis()-reloadStart >= reloadTime[int(saveData[1])]) { //checks if bulletsRemaining is none and checks if finished reloading
    bulletsRemaining = bullets[int(saveData[1])]; //bulletsRemaing
    reloading = false; //sets reloading false
  }
  else if (bulletsRemaining == 0){//checks if reload is needed
    reloading = true; //sets reloading true
  }
}

void charInfo() {
  fill(0);//adding fill
  textFont(regular[0], 48*scaleFactor[0]);//font type and size
  textAlign(LEFT);//changing text align
  text("Bullets remaining: " + bulletsRemaining, 48*scaleFactor[0], 48*scaleFactor[0]);//show bullets remaining
  text(int(distTravelled)+" m", 100*scaleFactor[0], 100*scaleFactor[0]);//shows distance travelled
  textAlign(RIGHT);//changing text align
  text("Money: $" + String.format("%,d", int(saveData[3])), width-48*scaleFactor[0], 48*scaleFactor[0]);//shows money the player has
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
    if (rotation >= PI/4 || rotation <= -PI/4) vR*=-1; //switches rotation to other direction
    rotation+=vR; //adds rotation speed to rotation
  }
  pushMatrix(); //starts transformation
  translate(pos[0], pos[1]+character[0].height/3); //moves to leg position
  rotate(rotation); //rotates to rotation
  image(character[2], 0, character[2].height/2); //displays leg
  rotate(-rotation*2); //rotates opposite to rotation
  image(character[2], 0, character[2].height/2); //displays leg
  popMatrix(); //ends transformation
  image(character[3],pos[0]-character[0].width/2-4*scaleFactor[0],pos[1]+9*scaleFactor[0]); //shows jetpack
  image(character[0], pos[0], pos[1]); //shows body
  if (int(saveData[2]) > 0) image(armour, pos[0], pos[1]+character[0].height/2-armour.height/2); //if armour is bought, it shows armour
  drawArms(); //calls function drawArms
}

//creates 2D list of obstacles, enemies, and enemyBullets
ArrayList<ArrayList<Float>> obstacles = new ArrayList<ArrayList<Float>>(); 
ArrayList<ArrayList<Float>> enemies = new ArrayList<ArrayList<Float>>(); 
ArrayList<ArrayList<Float>> enemyBullets = new ArrayList<ArrayList<Float>>();

void updateEnemies(){ //update and draws Enemies
  imageMode(CENTER); //allignsd all images to center of position
  for (int i = 0; i < enemies.size(); i++){ //loops through all list of enemies
    int currentGroundEnemy=0; //creates to int for determining which ground is the enemy on
    float bottomEnemy = enemies.get(i).get(1)+robot[0].height/3+robot[2].height; //position of bottom of enemy
    for(int j = 0; j < 2; j++){ //loops through all the groundPos
      if (enemies.get(i).get(0)>= groundPos[j][0] && enemies.get(i).get(0)<= groundPos[j][0]+background[0].width) currentGroundEnemy = j; //checks if the enemy is on a groundPosition
    }
    int nextGroundEnemy = (currentGroundEnemy+1)%2; //finds the next ground position
    float topGroundEnemy = groundPos[currentGroundEnemy][1]+49*scaleFactor[1]; //finds the top of the ground of where the enemy is on
    float nextTopGroundEnemy = groundPos[nextGroundEnemy][1]+49*scaleFactor[1]; //finds the next top of the ground of where the enemy will be on
    enemies.get(i).set(1, topGroundEnemy-(robot[0].height/3+robot[2].height)); //sets the enemy to be on the ground
    image(robot[0],enemies.get(i).get(0), enemies.get(i).get(1)); //draws the robot
    pushMatrix(); //begins robot transformation
    translate(enemies.get(i).get(0)-robot[1].width, enemies.get(i).get(1)); //moves to top of arm position
    scale(-1, 1); //flips image
    rotate(-PI/2); //rotates arm
    
    //draws gun
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
    popMatrix(); //ends transformation
    
    if (millis()-enemies.get(i).get(2) >= robotReload[int(saveData[1])] && enemies.get(i).get(0) < width){ //checks if gun is able to shoot and enemy is on screen
      ArrayList<Float> newBullet = new ArrayList<Float>(); //create to list for new bullet
      
      //puts x and y position of bullet to desired location
      newBullet.add(enemies.get(i).get(0)-robot[1].height); 
      if (int(saveData[1]) < 16)newBullet.add(enemies.get(i).get(1)-robot[1].width/6);
      else if (int(saveData[1]) <= 17)newBullet.add(enemies.get(i).get(1)-robot[1].width/6-guns[int(saveData[1])][0].width/5);
      else newBullet.add(enemies.get(i).get(1)-robot[1].width/6);
      
      enemyBullets.add(newBullet); //adds newBullet to enemyBullets
      enemies.get(i).set(4, 2.0); //add recoil and gun shot
      enemies.get(i).set(2, float(millis())); //record time last shot
    }
    if (enemies.get(i).get(4)!=0){ //updating recoil
      enemies.get(i).set(4, enemies.get(i).get(4)-enemies.get(i).get(5));
    }
    if (enemies.get(i).get(4) >= 10 || enemies.get(i).get(4) <= 0){ //reverses direction of recoil
      enemies.get(i).set(5, enemies.get(i).get(5)*-1);
    }
    image(robot[1], enemies.get(i).get(0)-robot[1].width/2, enemies.get(i).get(1)); // draws arm
    image(robot[2], enemies.get(i).get(0), enemies.get(i).get(1)+robot[0].height/3+robot[2].height/2); //draw robot tracks
    if (!(enemies.get(i).get(0)-int((int(speed)/3+10)*scaleFactor[1])*2>groundPos[nextGroundEnemy][0] && enemies.get(i).get(0)-int((int(speed)/3+10)*scaleFactor[1])*2 < groundPos[nextGroundEnemy][0]+background[0].width && bottomEnemy-nextTopGroundEnemy>5*scaleFactor[3])) enemies.get(i).set(0, enemies.get(i).get(0)-int((int(speed)/3+10)*scaleFactor[1])*2); //checks if robot will collide with ground and pushes robot back
    rectMode(CENTER);
    //drawing robot health
    fill(0);
    rect(enemies.get(i).get(0), enemies.get(i).get(1)-robot[0].height/2 - 50*scaleFactor[0], 200*scaleFactor[0], 40*scaleFactor[0]);
    fill(255, 0, 0);
    rectMode(CORNER);
    rect(enemies.get(i).get(0)-90*scaleFactor[0], enemies.get(i).get(1)-robot[0].height/2 - 60 * scaleFactor[0], 180*(enemies.get(i).get(3)/100)*scaleFactor[0], 20*scaleFactor[0]);
    if (enemies.get(i).get(0)+robot[2].width/2 <= 0){//checks if enemies is dead, and removes enemy
      enemies.remove(i);
      i--;
    }
  }
}

void drawUpdateObstacle(){ //drawing and updating obstacles
  imageMode(CENTER);
  for(int i = 0; i < obstacles.size(); i++){
    image(obstacleImages[int(obstacles.get(i).get(2))], obstacles.get(i).get(0), obstacles.get(i).get(1)-obstacleImages[int(obstacles.get(i).get(2))].height/2); //drawing obstacle according to what obstacle it is
    obstacles.get(i).set(0, obstacles.get(i).get(0)-int((int(speed)/3+5)*scaleFactor[1])*2); //moves obstacle towards player
    if (obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].height/2 <= 0){ //checks if obstacle is beyond screen and removes it
      obstacles.remove(i);
      i--;
    }
  }
}

void detectCollision(){ //detecting collisions
  for(int i = 0; i < bulletPos.size(); i++){//loops going through bullets
    int[] value = {-1, -1}; //create new array of determining closest object
    float closest = 1000000; //x position of closest
    float topOfClosest = 100000; //y top of closest
    float bottomOfClosest = 100000; //y bottom of closest
    float rightClosest = 1000000; //x right position of closest
    for (int j = 0; j < obstacles.size(); j++){ //loops through all obstacles
      //finding position of obstacles
      float top = obstacles.get(j).get(1) - obstacleImages[int(obstacles.get(j).get(2))].height;
      float left = obstacles.get(j).get(0) - obstacleImages[int(obstacles.get(j).get(2))].width/2;
      float right = obstacles.get(j).get(0) + obstacleImages[int(obstacles.get(j).get(2))].width/2;
      
      //checking if obstacle is closer
      if (left < closest && right < rightClosest && bulletPos.get(i).get(0) < right && bulletPos.get(i).get(1) > top&& bulletPos.get(i).get(1)<obstacles.get(j).get(1)){
        //sets positions to closest
        closest = left;
        rightClosest = right;
        topOfClosest = top;
        bottomOfClosest = obstacles.get(j).get(1);
        //tells value which obstacle is closest
        value[0] = j;
        value[1] = 0;
      }
    }
    for (int j = 0; j < enemies.size(); j++){ //loops through all enemies
      //finding position of enemies
      float bottom = enemies.get(j).get(1)+robot[0].height/3+robot[2].height;
      float top = enemies.get(j).get(1)-robot[0].height/2;
      float left = enemies.get(j).get(0)-robot[0].width/2;
      float right = enemies.get(j).get(0)+robot[0].width/2;
      
      //checking if enemy is closer
      if (left < closest && right < rightClosest && bulletPos.get(i).get(0) < right && bulletPos.get(i).get(1) > top && bulletPos.get(i).get(1) < bottom){
        //sets positions to closest
        closest = left;
        rightClosest = right;
        topOfClosest = top;
        bottomOfClosest = bottom;
        //tells value which enemy is closest
        value[0] = j;
        value[1] = 1;
      }
    }
    
    //checks if bullet is beyond closest object and resets values
    if (closest <= bulletPos.get(i).get(0) && rightClosest <= bulletPos.get(i).get(0)  || closest <= pos[0]-character[0].width/2){
      closest = 100000;
      rightClosest = 100000;
      value[0] = -1;
      value[1] = -1;
    }
    //checks if bullet is going to collide with closest object
    if (bulletPos.get(i).get(0)+60*scaleFactor[0] >= closest && bulletPos.get(i).get(1) > topOfClosest && bulletPos.get(i).get(1) < bottomOfClosest){
      if (value[1] == 1){ //checks if colliding with an enemy
        enemies.get(value[0]).set(3, enemies.get(value[0]).get(3)-dmg[int(saveData[1])]); //subtracts damage from enemy health
        if (enemies.get(value[0]).get(3) <= 0){ //checks if enemy health is below zero, and remove enemy and reset all values
          enemies.remove(value[0]);
          value[0] = -1;
          value[1] = -1;
          closest = 100000;
          rightClosest = 100000;
          saveData[3] = Integer.toString(int(saveData[3])+int(random(0, 11))*100);
        }
      }
      else{ //since it's not enemy, it must be colliding with an obstacle
        obstacles.get(value[0]).set(3, obstacles.get(value[0]).get(3)-dmg[int(saveData[1])]); //removes damage from obstacle health
        obstacles.get(value[0]).set(1, obstacles.get(value[0]).get(1)+obstacleImages[int(obstacles.get(value[0]).get(2))].height*(dmg[int(saveData[1])])/100); //lowers obstacle a bit
        if (obstacles.get(value[0]).get(3) <= 0){ //checks if obstacle health is below zero, and remove obstacle and reset all values
          obstacles.remove(value[0]);
          value[0] = -1;
          value[1] = -1;
          closest = 100000;
          rightClosest = 100000;
        }
      }
      if (int(saveData[1]) >= 18){ //checks if weapon is rpg
        for (int j = 0; j < enemies.size(); j++){ //searches all enemy values
          //finds distance to all enemies
          float distToEnemy = dist(bulletPos.get(i).get(0), bulletPos.get(i).get(1), enemies.get(j).get(0), enemies.get(j).get(1));
          if (distToEnemy <= 400*scaleFactor[1]){ //checks if the distance is less than or equal to 400
            enemies.remove(j); //removes enemy
            j--;
          }
        }
        for (int j = 0; j < obstacles.size(); j++){//searches all obstacle values
          //finds distance to all obstacles
          float distToObstacles = dist(bulletPos.get(i).get(0), bulletPos.get(i).get(1), obstacles.get(j).get(0), obstacles.get(j).get(1));
          if (distToObstacles <= 400*scaleFactor[1]){//checks if the distance is less than or equal to 400
            obstacles.remove(j); //removes obstacles
            j--;
          }
        }
      }
      if ((int(saveData[1]) != 15 && int(saveData[1]) != 14) || (bulletPos.get(i).get(2) >= 3)) bulletPos.remove(i); //checks if weapon isn't sniper, or has gone through 3 objects so it can remove bullet
      else bulletPos.get(i).set(2, bulletPos.get(i).get(2)+1); //if sniper, it adds one to objects gone through
    }
  }
  for (int i = 0; i < enemies.size(); i++){ //goes through all enemy values
    //finds position of enemy
    float right = enemies.get(i).get(0)+robot[0].width/2;
    float futureLeft = enemies.get(i).get(0)-robot[0].width/2-int((int(speed)/3+10)*scaleFactor[1])*2;
    float top = enemies.get(i).get(1)-robot[0].height/2;
    float bottom = enemies.get(i).get(1) + robot[0].height/3+robot[2].height;
    float bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;
    float topOfPlayer = pos[1]-character[0].height/2;
    //checks if enemy will hit the player, and then will damage the player and kill the enemy
    if (right > pos[0]-character[0].width/2 && futureLeft < pos[0]+character[0].width/2 && topOfPlayer < bottom && bottomOfPlayer > top){
      health -= enemies.get(i).get(3)/4;
      enemies.remove(i);
      i--;
    }
  }
}

void updateCoins(){ //function to update and draw coins
  imageMode(CENTER); //align coins to center
  for (int i = 0; i < coins.size(); i++){ //loop through all the coins
    image(coin, coins.get(i).get(0), coins.get(i).get(1)); //draw coins on screen
    coins.get(i).set(0, coins.get(i).get(0)-int((int(speed)/3+5)*scaleFactor[1])*2); //moves coins back a bit
    //checks if coin will collide with player, then it will remove coin and add a random number of money
    if (coins.get(i).get(1)-25*scaleFactor[0]>pos[1]-character[0].height/2&& coins.get(i).get(0)<pos[0]+character[0].width/2 && coins.get(i).get(0) > pos[0]-character[0].width/2 && coins.get(i).get(1)-25 < pos[1]+character[0].height/3+character[2].height){
      coins.remove(i);
      i--;
      saveData[3] = Integer.toString(int(saveData[3])+int(random(5,11))*100);
    }
    else if (coins.get(i).get(0)+coin.width/2 <= 0){ //checks if coins will go off screen and then it will remove the coins
      coins.remove(i);
      i--;
    }
  }
}

float nextHeight; //new variable for the change in next height
int next; //variable determining the next height

void game() { //function for actual game
  imageMode(CENTER);
  image(background[2], width/2, height/2); //showing blue sky
  nextHeight = random(-75*scaleFactor[3], 75*scaleFactor[3]); //creating random number for next heigt
  imageMode(CORNER);
  for (int i = 0; i < skyX.length; i++){ //going through all sky positions
    image(background[1], skyX[i], 0); //draws clouds
    if (!firstTime) skyX[i]-=int((int(speed)/4+1)*scaleFactor[1])+1; //moves skyX back only if not firstTime
    if (skyX[i] <= -background[1].width){ //if skyX is completely off the screen, it moves to the right and off the screen
      if (i == 0) next = 1;
      else next = 0;
      if (skyX[next] < 0) skyX[i] = width;
      else skyX[i] = skyX[next]+background[1].width;
    }
  }
  drawBullet(); //calls drawBullet function
  drawUpdateObstacle(); //calls drawUpdateObstacle function
  imageMode(CORNER);
  for (int i = 0; i < groundPos.length; i++) { //loops through the size of groundPos
    image(background[0], groundPos[i][0], groundPos[i][1]); //draw all the ground images
    if (groundPos[i][0] <= -background[0].width) { //checks if the ground is going beyond the screen
      //restores the ground to next position and changes the height with nextHeight
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
      //creates a random number of obstacles and adds them to obstacle list
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
      //creates a random number of enemies and adds them to enemy list
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
      //creates a random number of coins and adds them to coin list
      int numOfCoins = int(random(0, 4));
      for (int a = 0; a < numOfCoins; a++){
        ArrayList<Float> newCoin = new ArrayList<Float>();
        newCoin.add(random(groundPos[i][0]+100*scaleFactor[0], groundPos[i][0]+background[0].width-100*scaleFactor[0]));
        newCoin.add(groundPos[i][1]+34*scaleFactor[1]-25*scaleFactor[0]);
        coins.add(newCoin);
      }
    }
    if (!firstTime) groundPos[i][0]-=int((int(speed)/3+5)*scaleFactor[1])*2; //updates ground position if not first time, and moves ground back
  }
  updateCoins(); //calls on updateCoins
  updateEnemies(); //calls on updateEnemies
  detectCollision(); //calls on detectCollision
  if (!firstTime){ // checks if it not first time and updates player info, and other controls
    movePlayer();
    distTravelled=distTravelled+0.04*speed;
    speed=speed+speedUp/60;
    if(colliding){
      distTravelled=distTravelled-0.04*speed;
     }
    jetpack();
    if (pos[0] > 0 && health > 0){
      charInfo();
      drawChar();
    }
  }
  else { //if first time, shows all controls
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
    if (clicked){
      firstTime = false;
      bulletsRemaining++;
    }
  }
  if(pos[0]<=0 || health <= 0){ //shows player stats if dead or beyond screen
    speed=0;
    pos[0]=-1000;
    fill(0);
    textAlign(CENTER, CENTER);
    rectMode(CENTER);
    textFont(regular[1], 70*scaleFactor[0]);
    text("GAME OVER",width/2, height/2 - 120*scaleFactor[0]);
    text("Distance: "+int(distTravelled)+"m",width/2,height/2);
    int highscore = int(saveData[0]);
    if (int(distTravelled) > highscore) highscore = int(distTravelled);
    text("High score: " + highscore+"m", width/2, height/2+120*scaleFactor[0]);
    textFont(regular[0], 48*scaleFactor[0]);
    if (mouseX > width/2-300*scaleFactor[0] && mouseX < width/2 + 300*scaleFactor[0] && mouseY > height-130*scaleFactor[0] && mouseY < height-70*scaleFactor[0]){ //checks if button is pressed
      fill(127);
      if (clicked){ //updates all player stats, changes highscore if highscore is exceeded and returns to main menu and saves data
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
    // displays button to return to main menu
    rect(width/2, height-100*scaleFactor[0], 600*scaleFactor[0], 60*scaleFactor[0]);
    fill(0);
    text("Return to main menu", width/2, height-105*scaleFactor[0]);
    
  }
  if (justJumped) justJumped = false; //sets justJumped to false if true
}

void credits() { //loads credits, and license to font
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
  if (mouseOver && clicked) link("https://raw.githubusercontent.com/JulietaUla/Montserrat/master/OFL.txt"); //redirects player
  else if (clicked) currentScene = 0;
}

int[] selection = {int(saveData[1]), int(saveData[2]), int(saveData[7])}; //values of store selection

void shop(){ //game shop
  //shows title and money
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
  for (int i = 0; i < shopOptions[0].length; i++){ //goes through all shopOptions and displays them
    textFont(light[0], 40*scaleFactor[0]);
    fill(255);
    text(shopOptions[0][i], width/2, i*170*scaleFactor[0] + 180*scaleFactor[0]); //shows all avaliable options (i.e. gun upgrade, armour upgrade, jetpack upgrade)
    textFont(light[0], 30*scaleFactor[0]);
    if (i!=2){
      String price;
      if (selection[i] > int(saveData[i+4])+1) price = "LOCKED"; //if previous item hasn't been unlocked
      else if (selection[i] > int(saveData[i+4]))price = "$" + String.format("%,d", shopCosts[i][selection[i]]); //shows price of weapon if item is avaliable to be unlocked
      else if (selection[i] == int(saveData[i+1]))price = "SELECTED"; //shows item that's already being selected
      else price = "BOUGHT"; //shows item that's already purchased
      text(shopOptions[i+1][selection[i]] + " (" + price + ")", width/2, i*170*scaleFactor[0]+310*scaleFactor[0]); //displays item and price/avaliability
      //checks if button is going to be clicked
      if (mouseX >= width/2-40*scaleFactor[0] && mouseX <= width/2+40*scaleFactor[0] && mouseY >= i*170*scaleFactor[0]+210*scaleFactor[0] && mouseY <= i*170*scaleFactor[0]+290*scaleFactor[0]){
        fill(127);
        if (clicked){ //shows if it's being clicked
          if (selection[i] <= int(saveData[i+4]) || (int(saveData[3]) >= shopCosts[i][selection[i]] && selection[i] == int(saveData[i+4])+1)){ //switches item if it's avaliable 
            saveData[i+1] = Integer.toString(selection[i]);
            maxHealth = 100 + int(saveData[2])*20;
            health = maxHealth;
          }
          if (int(saveData[3]) >= shopCosts[i][selection[i]] && selection[i] == int(saveData[i+4])+1){ //removes money if item is purchasable
            saveData[3] = Integer.toString(int(saveData[3]) - shopCosts[i][selection[i]]);
            saveData[i+4] = Integer.toString(int(saveData[i+4])+1);
          }
          saveStrings("data/saveData/saveGame.txt", saveData); //updates saveData and saves
        }
      }
      else fill(255);
      rect(width/2, i*170*scaleFactor[0]+250*scaleFactor[0], 80*scaleFactor[0], 80*scaleFactor[0]); //rectangle for selection
      imageMode(CENTER);
      if (i == 0){ //shows all gun pictures in shop
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
      }
      //shows triangle to go one value down in selection and check if that button is pressed
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
      //shows triangle to go one value up in selection and check if that button is pressed
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
    else{ //displaying information about jetpack upgrades
      textAlign(CENTER);
      //checks if mouse if hovering over jetpack upgrade button
      if (mouseX >= width/2-150*scaleFactor[0] && mouseX <= width/2+150*scaleFactor[0] && mouseY >= i*170*scaleFactor[0]+210*scaleFactor[0] && mouseY <= i*170*scaleFactor[0]+290*scaleFactor[0]){
        fill(127);
        if (clicked){ //checks if button is pressed
          if (selection[i] <= int(saveData[i+4]) || int(saveData[3]) >= selection[2]*5000){ //if item is avaliable, it switches item
            saveData[7] = Integer.toString(selection[i]);
            maxFuel = 100+((int(saveData[7])+1)/2)*20;
            speedBoost = gravity*(int(saveData[7])/2.0);
            fuel = maxFuel;
          }
          if (int(saveData[3]) >= selection[2]*5000 && selection[i] > int(saveData[i+4])){ //if item can be purchased, money is removed
            saveData[3] = Integer.toString(int(saveData[3]) - 5000*selection[2]);
            saveData[i+4] = Integer.toString(int(saveData[i+4])+1);
          }
          saveStrings("data/saveData/saveGame.txt", saveData); //updates saveData and saves it
        }
      }
      else fill(255);
      rect(width/2, i*170*scaleFactor[0]+250*scaleFactor[0], 300*scaleFactor[0], 80*scaleFactor[0]);
      fill(0);
      if (selection[2] == 0){ //if selection is 0, shows stock item
        text("Stock", width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
      }
      else{ //shows what type of upgrade is avaliable
        if (selection[2]%2 == 1) text(shopOptions[i+1][selection[2]%2] + ((selection[2]+1)/2), width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
        else text(shopOptions[i+1][selection[2]%2] + (selection[2]/2), width/2, i*170*scaleFactor[0]+245*scaleFactor[0]);
      }
      //shows price or avaliability of jetpack upgrade
      if (selection[2] == int(saveData[7]) )text("(SELECTED)", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      else if (selection[2] > int(saveData[i+4])) text("($" + String.format("%,d", selection[2]*5000) + ")", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      else text("(BOUGHT)", width/2, i*170*scaleFactor[0]+275*scaleFactor[0]);
      //shows triangle to go one value down in selection and check if that button is pressed
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
      //shows triangle to go one value up in selection and check if that button is pressed
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
  //shows button for returning to main menu and being able to return to main menu
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
  //currentScene selects which scene is being shown
  if (currentScene == 0) mainMenu();
  else if (currentScene == 2) shop();
  else if (currentScene == 3) credits();
  else if (currentScene == 1) game();
  else if (currentScene == 4) exit(); //exits game
  
  if (clicked) clicked = false; //if clicked, returns click to false
}
