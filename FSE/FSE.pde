/*ICS2O Final Summative Evaluation
 By Gordon Lin and Daniel Weng
 */

//Set memory limit to 2048, as this uses a lot of RAM

int currentScene = 0;//shows what is on screen: 0 - main menu, 1 - game, 2 - shop, 3 -credits
//initializing all fonts
PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];


String[] saveData = {"0", "1", "0", "10000", "0", "0", "0", "0"}; //0th value: past distance, 1st value: gun type, 2nd value: armour type, 3rd value: money, 4th value: top gun purchased, 5th value: top armour purchased, 6th value: top jetpack, 7th value: jetpack
//craeting image variables
PImage[] character = new PImage[4];//player image
PImage bullet;//bullet image
PImage[] obstacleImages = new PImage[2];//obsatcle image
PImage[] robot = new PImage[3];//robot image
PImage mainMenuPic;
PImage[][] guns = new PImage[20][];

int[] reloadTime = {1500, 2500};//shows reload time for all guns

//initializing gravity
int JUMPPOWER=-12;
float gravity=0.6;
boolean jump=false;

//position of player
float pos[] = {500.0, 0.0};

float vy=0;//delta-y

int[] bullets = {12, 7};//bullet capacity
int[] dmg = {25, 40};//bullet damage
int[] robotReload = {1500, 2250};//shows reload time for robots
int bulletsRemaining = 0;//bullets remaining

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();//2D list for trail

float distTravelled=0;//current distance travelled
float speed=1;//current speed
float speedUp=0.1;//increasing speed

PImage background[] = new PImage[3];//background image

float[][] groundPos = {{0, height+400}, {1280, height+random(-75, 75)+400}};//shows ground position

//initializing ground
float topOfGrass = 0;
float topOfNextGrass = 0;
int nextGround = 0;
int current = 0;
float bottomOfPlayer = 0;
boolean onGround = true;
boolean colliding = false;
boolean gap = false;

int health=100;//health of player
float fuel=100;//fuel of player
ArrayList<ArrayList<Float>> coins = new ArrayList<ArrayList<Float>>();//2D list for coins

boolean onObstacle = false;//on or off obstacle
float topOfObstacle = 0;
float rightOfObstacle = 0;

void movePlayer() {
  bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;//finds bottom of player
  pos[1]+=vy;//moving the player up/down
  for (int i = 0; i < 2; i++){
    if (pos[0]>= groundPos[i][0] && pos[0]<= groundPos[i][0]+background[0].width) current = i;//finds the ground the player's on
  }
  nextGround = (current+1)%2;
  topOfGrass = groundPos[current][1]+49;
  topOfNextGrass = groundPos[nextGround][1]+49;
  if (onGround) pos[1]=topOfGrass-(character[0].height/3+character[2].height);
  else if (onObstacle) pos[1] = topOfObstacle - (character[0].height/3+character[2].height);
  else vy+=gravity;
  if (groundPos[nextGround][0]-int(speed)/3+1 <= pos[0]+character[0].width/2 && bottomOfPlayer-topOfNextGrass >= 10 && groundPos[nextGround][0] > 0){
    pos[0]-= int(speed)/3+6;
    colliding = true;
  }
  else{
    colliding = false;
  }
  if (pos[0] < 500 && pos[0]>0){
    pos[0]++;
  }
  if (!onGround && bottomOfPlayer >= topOfGrass && !justJumped){
    vy = 0;
    onGround = true;
  }
  for (int i = 0; i < obstacles.size(); i++){
    float top = obstacles.get(i).get(1);
    float left = obstacles.get(i).get(0)-obstacleImages[int(obstacles.get(i).get(2))].width/3;
    float right = obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].width/3;
    float futureLeft = left-(int(speed)/3+5);
    top-=obstacleImages[int(obstacles.get(i).get(2))].height*((obstacles.get(i).get(2)+1)/2);
    if(left <= pos[0]+character[0].width/2 && right >= pos[0]-character[0].width/2 && bottomOfPlayer > top){
      onObstacle = true;
      topOfObstacle = top;
      rightOfObstacle = right;
      pos[1] = topOfObstacle - (character[0].height/3+character[2].height);
      vy=0;
    }
    else if (left > pos[0]+character[0].width/2 && futureLeft < pos[0]+character[0].width/2 && right > pos[0]-character[0].width/2 && top<bottomOfPlayer)  pos[0]-= int(speed)/3+6;
  }
  if (rightOfObstacle < pos[0]-character[0].width/2 || bottomOfPlayer != topOfObstacle && onObstacle) onObstacle = false;
  //apply gravity
}


void initFont() {
  for (int i = 0; i < regular.length; i++) {
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48);
    xLight[i] = createFont("Font/Montserrat-ExtraLight.ttf", (i+1)*48);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48);
  }
}

void initImgs() {
  character[0] = loadImage("Imgs/Character Body.png");
  character[1] = loadImage("Imgs/Character Arm.png");
  character[2] = loadImage("Imgs/Character Leg.png");
  character[3] = loadImage("Imgs/Jetpack.png");
  
  guns[0] = new PImage[2];
  guns[0][0] = loadImage("Imgs/Glock Shell.png");
  guns[0][1] = loadImage("Imgs/Glock Side.png");
  
  guns[1] = new PImage[2];
  guns[1][0] = loadImage("Imgs/Deagle Shell.png");
  guns[1][1] = loadImage("Imgs/Deagle Slide.png");
  
  background[0] = loadImage("Imgs/Grass.png");
  background[1] = loadImage("Imgs/Clouds.png");
  background[2] = loadImage("Imgs/Blue Sky.png");
  background[0].resize(width, background[0].height*2/3);
  
  bullet = loadImage("Imgs/Bullet.png");
  bullet.resize(bullet.width*5, bullet.height*5);
  
  obstacleImages[0] = loadImage("Imgs/Tree.png");
  obstacleImages[1] = loadImage("Imgs/Bricks.png");
  
  robot[0] = loadImage("Imgs/Robot.png");
  robot[1] = loadImage("Imgs/Robot Arm.png");
  robot[2] = loadImage("Imgs/Robot Leg.png");
  
  for (int i = 0; i < 4; i++) {
    character[i].resize(character[i].width*3/4, character[i].height*3/4);
    if(i!=3){
      robot[i].resize(robot[i].width*3/4, robot[i].height*3/4);
    }
  }
  
  character[1].resize(character[1].width*3/4, character[1].height*3/4);
  robot[1].resize(robot[1].width*3/4, robot[1].height*3/4);
  mainMenuPic = loadImage("Imgs/Main Menu Screen.png");
  mainMenuPic.resize(width, height);
}

String[][] shopOptions = new String[4][];
int[][] shopCosts = new int[2][];

void setup() {
  size(1280, 720);
  initFont();
  initImgs();
  if (loadStrings("data/saveData/saveGame.txt") != null) {
    saveData = loadStrings("data/saveData/saveGame.txt");
  }
  frameRate(60);
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
}

boolean[] buttons = {false, false, false, false};
String[] buttonText = {"Play Game", "Shop", "Credits", "Exit"};
boolean firstTime;

void mainMenu() {
  background(100);
  imageMode(CENTER);
  image(mainMenuPic, width/2, height/2);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("ZapZpeed", width/2, 100);
  textFont(light[0], 48);
  rectMode(CENTER);
  for (int i = 0; i < 4; i++){
    if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60+i*100 && mouseY < height/2+20+i*100) buttons[i] = true;
    else buttons[i] = false;
    if (buttons[i]){
      fill(0);
      if(clicked){
        currentScene = i+1;
        if(i == 0) bulletsRemaining = bullets[int(saveData[1])];
      }
    }
    else fill(255,170);
    rect(width/2, height/2-20+100*i, 300, 80);
    if(buttons[i]) fill(255);
    else fill(0);
    text(buttonText[i], width/2, height/2-25+100*i);
  }
  if (int(saveData[0]) == 0){
    firstTime = true;
  }
}

boolean justJumped = false;
boolean holding = false;

void keyPressed() {
  if (keyCode == 87 && (onGround || onObstacle) && !justJumped && pos[0]>0 && !holding && currentScene == 1 && !firstTime) {//only jump if on ground
    vy=JUMPPOWER;//jumping power
    onGround = false;
    justJumped = true;
    holding = true;
  }
}//end keyPressed

boolean clicked = false;

void mousePressed(){
  clicked = true;
}

void mouseReleased(){
  clicked = false;
}

void keyReleased() {
  if (key == 'w'){
    justJumped = false;
    holding = false;
  }
}


float rotation = 0;
float vR = radians(8.5);

float recoil = 0;
float vRecoil = 0;

void addTrail() {

  ArrayList<Float> newTrail = new ArrayList<Float>();
  newTrail.add(pos[0]-20);
  newTrail.add(pos[1]);
  newTrail.add(rotation);
  newTrail.add(recoil);
  trail.add(newTrail);
}

void jetpack() {
  boolean jetpackUse = false;
  if (keyPressed && key==32 && fuel >= 0) {
    if (pos[1] > -character[0].height/2){
      vy=-3*gravity;
      onGround = false;
      onObstacle = false;
    }
    else vy = 0;
    jetpackUse = true;
  }
  else jetpackUse = false;
  if(jetpackUse && !onGround){
    fuel-=0.5;
  }
  else if(fuel<100 && vy>=0 && !jetpackUse && onGround){
    fuel+=0.5;
  }
  fill(0);
  rectMode(CORNER);
  rect(600,140,fuel,20);
}

void updateTrail() {
  for (int i = 0; i < trail.size(); i++) {
    tint(255, (trail.get(i).get(0) / pos[0])*150);
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
      switch(int(saveData[1])){
        case 0:
          image(guns[0][0], 5, character[1].height);
          image(guns[0][1], 2+guns[0][0].width/2, character[1].height-trail.get(i).get(3));
          break;
         case 1:
           image(guns[1][0], 5, character[1].height);
           image(guns[1][1], guns[1][0].width/2+guns[1][1].width/4, character[1].height-recoil);
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    }
    else {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(-PI/2);
      switch(int(saveData[1])){
        case 0:
          image(guns[0][0], 5, character[1].height);
          image(guns[0][1], 2+guns[0][0].width/2, character[1].height-trail.get(i).get(3));
          break;
         case 1:
           image(guns[1][0], 5, character[1].height);
           image(guns[1][1], guns[1][0].width/2+guns[1][1].width/4, character[1].height-recoil);
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    }
    trail.get(i).set(0, trail.get(i).get(0)-int(speed)/3-10);
    if (trail.get(i).get(0)+character[0].width < 0 || trail.get(i).get(0)/pos[0]*200 < 10) {
      trail.remove(i);
    }
  }
}

boolean justFired = false;
float reloadStart = 0;

ArrayList<ArrayList<Float>> bulletPos = new ArrayList<ArrayList<Float>>();

void addBullet(){
  ArrayList<Float> newBullet = new ArrayList<Float>();
  switch(int(saveData[1])){
    case 0:
      newBullet.add(pos[0]+character[0].width/2);
      newBullet.add(pos[1]-character[1].width/2);
    case 1:
      newBullet.add(pos[0]+character[0].width/2);
      newBullet.add(pos[1]-character[1].width/2);
  }
  bulletPos.add(newBullet);
}

void drawBullet(){
  imageMode(CENTER);
  for(int i = 0; i < bulletPos.size(); i++){
    image(bullet, bulletPos.get(i).get(0), bulletPos.get(i).get(1));
    bulletPos.get(i).set(0, bulletPos.get(i).get(0)+30);
    if (bulletPos.get(i).get(0)-bullet.width/2 > width || (bulletPos.get(i).get(0)+bullet.width/2>groundPos[nextGround][0] && bulletPos.get(i).get(1) > topOfNextGrass && groundPos[nextGround][0] > 0)) bulletPos.remove(i);
  }
  for (int i = 0; i < enemyBullets.size(); i++){
    image(bullet, enemyBullets.get(i).get(0), enemyBullets.get(i).get(1));
    enemyBullets.get(i).set(0, enemyBullets.get(i).get(0)-30);
    if (enemyBullets.get(i).get(0)-bullet.width/2 < 0){
      enemyBullets.remove(i);
    }
  }
}
boolean reloading = false;
void drawArms() {
  rectMode(CENTER);
  pushMatrix();
  translate(pos[0], pos[1]);
  if (mousePressed && !justFired && bulletsRemaining > 0) {
    vRecoil = 2;
    recoil=2;
    if (int(saveData[1]) <= 1) justFired = true;
    bulletsRemaining--;
    if (bulletsRemaining == 0) reloadStart = millis();
    addBullet();
  } else if (!mousePressed && recoil == 0) {
    justFired = false;
  }
  if (recoil >= 10) {
    vRecoil*=-1;
  }
  if (recoil != 0 && pos[0] > 0 && !reloading) {
    recoil+=vRecoil;
    rotate(-PI/2);
  } else if(pos[0]>0) rotate(rotation);
  switch(int(saveData[1])){
    case 0:
      image(guns[0][0], 5, character[1].height);
      image(guns[0][1], guns[0][1].width/4+guns[0][0].width/2, character[1].height-recoil);
      break;
    case 1:
      image(guns[1][0], 5, character[1].height);
      image(guns[1][1], guns[1][0].width/2+guns[1][1].width/4, character[1].height-recoil);
  }
  image(character[1], 0, character[1].height/2);
  rectMode(CENTER);
  popMatrix();
  if (bulletsRemaining == 0 && millis()-reloadStart >= reloadTime[int(saveData[1])]) {
    bulletsRemaining = bullets[int(saveData[1])];
    recoil = 2;
    vRecoil = 2;
    reloading = false;
  }
  else if (bulletsRemaining == 0){
    reloading = true;
  }
  drawBullet();
}

void charInfo() {
  fill(0);
  textFont(regular[0], 48);
  textAlign(LEFT);
  text("Bullets remaining: " + bulletsRemaining, 48, 48);
  text(int(distTravelled)+" m", 100, 100);
  textAlign(RIGHT);
  text("Money: $" + int(saveData[3]), width-100, 48);
}

void drawChar() {
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= pos[0]-character[0].width*1.75 || trail.get(trail.size()-1).get(1) > pos[1]+character[0].height*1.75 || trail.get(trail.size()-1).get(1)+character[0].height*1.75 < pos[1]) addTrail();
  imageMode(CENTER);
  updateTrail();
  tint(255, 255);
  fill(0, 255, 0);
  if (pos[0] > 0) {
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
  image(character[3],pos[0]-character[0].width/2-5,pos[1]+10);
  image(character[0], pos[0], pos[1]);
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
    float topGroundEnemy = groundPos[currentGroundEnemy][1]+49;
    float nextTopGroundEnemy = groundPos[nextGroundEnemy][1]+49;
    enemies.get(i).set(1, topGroundEnemy-(robot[0].height/3+robot[2].height));
    image(robot[0],enemies.get(i).get(0), enemies.get(i).get(1));
    pushMatrix();
    translate(enemies.get(i).get(0)-robot[1].width, enemies.get(i).get(1));
    scale(-1, 1);
    rotate(-PI/2);
    switch(int(saveData[1])){
      case 0:
        image(guns[0][0], 5, 0);
        image(guns[0][1], guns[0][1].width/4+guns[0][0].width/2, -enemies.get(i).get(4));
        break;
      case 1:
        image(guns[1][0], 5, 0);
        image(guns[1][1], guns[1][0].width/2+guns[1][1].width/4, -enemies.get(i).get(4));
        break;
    }
    popMatrix();
    if (millis()-enemies.get(i).get(2) >= robotReload[int(saveData[1])]){
      ArrayList<Float> newBullet = new ArrayList<Float>();
      newBullet.add(enemies.get(i).get(0)-robot[1].width);
      newBullet.add(enemies.get(i).get(1)-2-guns[0][0].width/2);
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
    if (!(enemies.get(i).get(0)-(int(speed)/3+10)>groundPos[nextGroundEnemy][0] && enemies.get(i).get(0)-(int(speed)/3+10) < groundPos[nextGroundEnemy][0]+background[0].width && bottomEnemy-nextTopGroundEnemy>5)) enemies.get(i).set(0, enemies.get(i).get(0)-(int(speed)/3+10));
    rectMode(CENTER);
    fill(0);
    rect(enemies.get(i).get(0), enemies.get(i).get(1)-robot[0].height/2 - 50, 200, 40);
    fill(255, 0, 0);
    rectMode(CORNER);
    rect(enemies.get(i).get(0)-90, enemies.get(i).get(1)-robot[0].height/2 - 50 - 10, 180*(enemies.get(i).get(3)/100), 20);
    if (enemies.get(i).get(0)+robot[2].width/2 <= 0) enemies.remove(i);
  }
}

void drawUpdateObstacle(){
  imageMode(CENTER);
  for(int i = 0; i < obstacles.size(); i++){
    image(obstacleImages[int(obstacles.get(i).get(2))], obstacles.get(i).get(0), obstacles.get(i).get(1)-obstacleImages[int(obstacles.get(i).get(2))].height/2);
    obstacles.get(i).set(0, obstacles.get(i).get(0)-(int(speed)/3+5));
    if (obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].height/2 <= 0) obstacles.remove(i);
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
    if (bulletPos.get(i).get(0)+30 >= closest && bulletPos.get(i).get(1) > topOfClosest && bulletPos.get(i).get(1) < bottomOfClosest){
      bulletPos.remove(i);
      if (value[1] == 1){
        enemies.get(value[0]).set(3, enemies.get(value[0]).get(3)-dmg[int(saveData[1])]);
        if (enemies.get(value[0]).get(3) <= 0){
          enemies.remove(value[0]);
          value[0] = -1;
          value[1] = -1;
          closest = 100000;
          rightClosest = 100000;
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

void health(){
  fill(255,0,0);
  rectMode(CORNER);
  rect(600,50,health,20);
}

void game() {
  imageMode(CENTER);
  image(background[2], width/2, height/2);
  nextHeight = random(-75, 75);
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
  drawUpdateObstacle();
  imageMode(CORNER);
  for (int i = 0; i < groundPos.length; i++) {
    if(pos[1]>groundPos[i][1]-100 && pos[0]<groundPos[i][0]+305 && pos[0]>groundPos[i][0]+295){
      colliding=true;
    }
    fill(0);
    image(background[0], groundPos[i][0], groundPos[i][1]);
    if (groundPos[i][0] <= -background[0].width) {
      if (i == 0) next = 1;
      else next = 0;
      if (groundPos[next][1]+nextHeight > height-50) {
        groundPos[i][1] = height-50;
      }
      else if (groundPos[next][1]+nextHeight < height-400){
        groundPos[i][1] = height-400;
      }
      else groundPos[i][1] = groundPos[next][1]+nextHeight;
      groundPos[i][0] = groundPos[next][0]+background[0].width;
      int randomNumber = int(random(0, 4));
      for (int a = 0; a < randomNumber; a++){
        ArrayList<Float> newObstacle = new ArrayList<Float>();
        float whatObstacle = int(random(0, 2));
        newObstacle.add(random(groundPos[i][0]+obstacleImages[0].width, groundPos[i][0]+background[0].width-obstacleImages[0].width));
        newObstacle.add(groundPos[i][1]+34);
        newObstacle.add(whatObstacle);
        newObstacle.add(100.0);
        obstacles.add(newObstacle);
      }
      int numOfEnemies = int(random(0, 4));
      for (int a = 0; a < numOfEnemies; a++){
        ArrayList<Float> newEnemy = new ArrayList<Float>();
        newEnemy.add(random(groundPos[i][0]+robot[2].width, groundPos[i][0]+background[0].width-robot[2].width));
        newEnemy.add(groundPos[i][1]+34);
        newEnemy.add(float(millis()));
        newEnemy.add(100.0);
        newEnemy.add(0.0);
        newEnemy.add(2.0);
        enemies.add(newEnemy);
      }
    }
    if (!firstTime) groundPos[i][0]-=int(speed)/3+5;
  }
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
    health();
    //addCoins();
  }
  else {
    rectMode(CENTER);
    fill(0, 200);
    rect(width/2, height/2, width*0.8, height*0.8);
    fill(255);
    textFont(regular[1], 70);
    textAlign(CENTER, CENTER);
    text("Rules to the game", width/2, height/2-height*0.4+100);
    textFont(light[0], 48);
    text("Press W to jump, Space to use jetpack,", width/2, height/2-80);
    text("and Left Click to shoot.", width/2, height/2-20);
    text("Go the furthest distance without dying!", width/2, height/2+40);
    text("Press anywhere to continue", width/2, height/2+150);
    if (clicked) firstTime = false;
  }
  if(pos[0]<=0 || health <= 0){
    speed=0;
    pos[0]=-1000;
    fill(0);
    textAlign(CENTER, CENTER);
    textFont(regular[1], 70);
    text("GAME OVER",width/2, height/2 - 50);
    text("Distance: "+int(distTravelled)+"m",width/2,height/2 + 50);
    textFont(regular[0], 48);
    text("Press anywhere to return to main menu", width/2, height-100);
    if (clicked){
      currentScene = 0;
      pos[0] = 500;
      pos[1] = 0;
      vy = 0;
      bulletsRemaining = 0;
      speed = 1;
      speedUp = 0.1;
      if (int(saveData[0]) < distTravelled) saveData[0] = Integer.toString(int(distTravelled));
      distTravelled = 0;
      obstacles.clear();
      reloading = false;
      health = 100;
      enemies.clear();
      //saveStrings("saveGame.txt", saveData);
    }
  }
  else if (!firstTime) charInfo();
  if (justJumped) justJumped = false;
}

void credits() {
  background(100);
  imageMode(CENTER);
  image(mainMenuPic, width/2, height/2);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  fill(255);
  text("Credits", width/2, 100);
  textFont(light[0], 48);
  text("Sprites made by: Gordon Lin", width/2, 200);
  text("Code made by: Gordon Lin and Daniel Weng", width/2, 280);
  text("Font made by: Montserrat Project Authors", width/2, 360);
  boolean mouseOver = mouseX > width/2-450 && mouseX < width/2+450 && mouseY > 400 && mouseY < 480;
  text("Press anywhere to return to main menu", width/2, height-100);
  rectMode(CENTER);
  if (mouseOver) fill(0);
  rect(width/2, 440, 900, 80);
  if (!mouseOver) fill(0);
  else fill(255);
  text("Click here to view license for font", width/2, 440);
  if (mouseOver && clicked) link("https://raw.githubusercontent.com/JulietaUla/Montserrat/master/OFL.txt");
  else if (clicked) currentScene = 0;
}

int[] selection = {int(saveData[1]), int(saveData[2]), int(saveData[6])};

void shop(){
  background(0);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("Shop",width/2, 70);
  rectMode(CENTER);
  textFont(regular[0], 48);
  textAlign(RIGHT, CENTER);
  text("Money: $" + String.format("%d", int(saveData[3])), width-20, 70);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < shopOptions[0].length; i++){
    textFont(light[0], 40);
    fill(255);
    text(shopOptions[0][i], width/2, i*170 + 180);
    textFont(light[0], 30);
    if (i!=2){
      String price;
      if (selection[i] > int(saveData[i+4]))price = "$" + String.format("%,d", shopCosts[i][selection[i]]);
      else price = "BOUGHT";
      text(shopOptions[i+1][selection[i]] + " (" + price + ")", width/2, i*170+310);
      if (mouseX > width/2-40 && mouseX < width/2+40 && mouseY > i*170+210 && mouseY < i*170+290){
        fill(127);
      }
      else fill(255);
      rect(width/2, i*170+250, 80, 80);
      imageMode(CENTER);
      switch(i){
        case 0:
          pushMatrix();
          translate(width/2, i*170+250);
          rotate(-PI/2);
          switch(selection[0]){
            case 0:
              image(guns[0][0], 0, 0);
              image(guns[0][1], guns[0][0].width/2-guns[0][1].width/2, 0);
              break;
            case 1:
              image(guns[1][0], 0, 0);
              image(guns[1][1], guns[1][0].width/2-guns[1][1].width/2, 0);
              break;
          }
          popMatrix();
          break;
      }
      int[] areas = {abs(((width/2-50)-mouseX) * ((i*170+290)-mouseY) - ((width/2-50)-mouseX) * ((i*170+210)-mouseY)), abs(((width/2-50)-mouseX)*((i*170+250)-mouseY) - ((width/2-90) - mouseX) * ((i*170+290)-mouseY)), abs(((width/2-90)-mouseX)*((i*170+210)-mouseY) - ((width/2-50)-mouseX) * ((i*170+250)-mouseY))};
      if (areas[0]  + areas[1] + areas[2]== abs(((width/2-50)-(width/2-50))*((i*170+250)-(i*170+210)) - ((width/2-90)-(width/2-50))*((i*170+290) - (i*170+210)))){
        fill(127);
        if (clicked && selection[i] > 0) selection[i]--;
      }
      else fill (255);
      beginShape();
      vertex(width/2-50, i*170+210);
      vertex(width/2-50, i*170+290);
      vertex(width/2-90, i*170+250);
      endShape();
      int[] areas1 = {abs(((width/2+50)-mouseX) * ((i*170+290)-mouseY) - ((width/2+50)-mouseX) * ((i*170+210)-mouseY)), abs(((width/2+50)-mouseX)*((i*170+250)-mouseY) - ((width/2+90) - mouseX) * ((i*170+290)-mouseY)), abs(((width/2+90)-mouseX)*((i*170+210)-mouseY) - ((width/2+50)-mouseX) * ((i*170+250)-mouseY))};
      if (areas1[0]  + areas1[1] + areas1[2]== abs(((width/2+50)-(width/2+50))*((i*170+250)-(i*170+210)) - ((width/2+90)-(width/2+50))*((i*170+290) - (i*170+210)))){
        fill(127);
        if ((clicked && (selection[i] < shopOptions[i+1].length-1)||(i == 2 && selection[i]<int(saveData[6]))) && selection[i] <= int(saveData[i+4])) selection[i]++;
      }
      else fill (255);
      beginShape();
      vertex(width/2+50, i*170+210);
      vertex(width/2+50, i*170+290);
      vertex(width/2+90, i*170+250);
      endShape();
    }
    else{
      textAlign(CENTER);
      rect(width/2, i*170+250, 200, 80);
      fill(0);
      if (selection[2] == 0){
        text("Bought", width/2, i*170+245);
        text("($1,000,000)", width/2, i*170+275);
      }
      int[] areas = {abs(((width/2-110)-mouseX) * ((i*170+290)-mouseY) - ((width/2-110)-mouseX) * ((i*170+210)-mouseY)), abs(((width/2-110)-mouseX)*((i*170+250)-mouseY) - ((width/2-150) - mouseX) * ((i*170+290)-mouseY)), abs(((width/2-150)-mouseX)*((i*170+210)-mouseY) - ((width/2-110)-mouseX) * ((i*170+250)-mouseY))};
      if (areas[0]  + areas[1] + areas[2]== abs(((width/2-110)-(width/2-110))*((i*170+250)-(i*170+210)) - ((width/2-150)-(width/2-110))*((i*170+290) - (i*170+210)))){
        fill(127);
        if (clicked && selection[i] > 0) selection[i]--;
      }
      else fill (255);
      beginShape();
      vertex(width/2-110, i*170+210);
      vertex(width/2-110, i*170+290);
      vertex(width/2-150, i*170+250);
      endShape();
      int[] areas1 = {abs(((width/2+110)-mouseX) * ((i*170+290)-mouseY) - ((width/2+110)-mouseX) * ((i*170+210)-mouseY)), abs(((width/2+110)-mouseX)*((i*170+250)-mouseY) - ((width/2+150) - mouseX) * ((i*170+290)-mouseY)), abs(((width/2+150)-mouseX)*((i*170+210)-mouseY) - ((width/2+110)-mouseX) * ((i*170+250)-mouseY))};
      if (areas1[0]  + areas1[1] + areas1[2]== abs(((width/2+110)-(width/2+110))*((i*170+250)-(i*170+210)) - ((width/2+150)-(width/2+110))*((i*170+290) - (i*170+210)))){
        fill(127);
        if ((clicked && (selection[i] < shopOptions[i+1].length-1)||(i == 2 && selection[i]<int(saveData[6]))) && selection[i] <= int(saveData[i+4])) selection[i]++;
      }
      else fill (255);
      beginShape();
      vertex(width/2+110, i*170+210);
      vertex(width/2+110, i*170+290);
      vertex(width/2+150, i*170+250);
      endShape();
    }
  }
}

void draw() {
  if (currentScene == 0) mainMenu();
  else if (currentScene == 2) shop();
  else if (currentScene == 3) credits();
  else if (currentScene == 1) game();
  else if (currentScene == 4) exit();
  if (clicked) clicked = false;
}
