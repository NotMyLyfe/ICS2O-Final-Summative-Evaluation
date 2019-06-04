/*ICS2O Final Summative Evaluation
 By Gordon Lin and Daniel Weng
 */

//Set memory limit to 2048, as this uses a lot of RAM

int currentScene = 0;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

String[] saveData = {"0", "0", "0", "10000"}; //0th value: past distance, 1st value: gun type, 2nd value: armour type, 3rd value: money

float loadError = 0;

float time = 0;

PImage[] character = new PImage[4];
PImage[] glock = new PImage[2];
PImage bullet;
PImage[] obstacleImages = new PImage[2];
PImage cyborg;

int[] reloadTime = {4000};

int JUMPPOWER=-12;
float gravity=0.6;
boolean jump=false;

float pos[] = {500.0, 0.0};

float vy=0;
float angle=0;

int[] bullets = {12};
int[] dmg = {10};
int bulletsRemaining = 0;

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();

float distTravelled=0;
float speed=1;
float speedUp=0.1;

PImage background[] = new PImage[3];

float[][] groundPos = {{0, height+400}, {1280, height+random(-75, 75)+400}};

float topOfGrass = 0;
float topOfNextGrass = 0;
int nextGround = 0;
int current = 0;
float bottomOfPlayer = 0;
boolean onGround = true;
boolean colliding = false;
boolean gap = false;

int health;

void movePlayer() {
  bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;
  pos[1]+=vy;//moving the player up/down
  for (int i = 0; i < 2; i++){
    if (pos[0]>= groundPos[i][0] && pos[0]<= groundPos[i][0]+background[0].width) current = i;
  }
  if (current == 0) nextGround = 1;
  else nextGround = 0;
  topOfGrass = groundPos[current][1]+49;
  topOfNextGrass = groundPos[nextGround][1]+49;
  if (onGround) pos[1]=topOfGrass-(character[0].height/3+character[2].height);
  else if (!colliding || (colliding && !onGround)) vy+=gravity;
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
  for (int i = 0; i < 4; i++) {
    character[i].resize(character[i].width*3/4, character[i].height*3/4);
  }
  character[1].resize(character[1].width*3/4, character[1].height*3/4);
  glock[0] = loadImage("Imgs/Glock Shell.png");
  glock[1] = loadImage("Imgs/Glock Side.png");
  background[0] = loadImage("Imgs/Grass.png");
  background[1] = loadImage("Imgs/Clouds.png");
  background[2] = loadImage("Imgs/Blue Sky.png");
  background[0].resize(width, background[0].height*2/3);
  bullet = loadImage("Imgs/Bullet.png");
  bullet.resize(bullet.width*5, bullet.height*5);
  obstacleImages[0] = loadImage("Imgs/Tree.png");
  obstacleImages[1] = loadImage("Imgs/Bricks.png");
  cyborg = loadImage("Imgs/Cyborg.png");
}

void setup() {
  size(1280, 720);
  initFont();
  initImgs();
  if (loadStrings("saveGame.txt") != null) {
    saveData = loadStrings("saveGame.txt");
  }
  frameRate(60);
}

boolean[] buttons = {false, false, false, false};
String[] buttonText = {"Play Game", "Shop", "Credits", "Exit"};
boolean firstTime;

void mainMenu() {
  background(0);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("Ultimate Dash", width/2, 100);
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
    else fill(255);
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
  if (key=='w' && onGround && !justJumped && pos[0]>0 && !holding && currentScene == 1 && !firstTime) {//only jump if on ground
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
  if (key==32) {
    jump=false;
  }
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
  if (keyPressed && key==32 && !colliding) {
    jump=true;
    if (vy>=0 && jump) {
      vy=2*gravity;
    }
  }
}

void updateTrail() {
  for (int i = 0; i < trail.size(); i++) {
    tint(255, (trail.get(i).get(0) / pos[0])*150);
    pushMatrix();
    translate(trail.get(i).get(0), trail.get(i).get(1)+character[0].height/3);
    rotate(trail.get(i).get(2));
    image(character[2], 0, character[1].height/2);
    rotate(-trail.get(i).get(2)*2);
    image(character[2], 0, character[1].height/2);
    popMatrix();
    image(character[0], trail.get(i).get(0), trail.get(i).get(1));
    if (trail.get(i).get(3)==0 || reloading) {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(trail.get(i).get(2));
      if (int(saveData[1]) == 0) {
        image(glock[0], 5, character[1].height);
        image(glock[1], 2+glock[0].width/2, character[1].height-trail.get(i).get(3));
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    }
    else {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(-PI/2);
      if (int(saveData[1]) == 0) {
        image(glock[0], 5, character[1].height);
        image(glock[1], 2+glock[0].width/2, character[1].height-trail.get(i).get(3));
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
  if (int(saveData[1]) == 0){
    newBullet.add(pos[0]+character[1].height+glock[0].height-10);
    newBullet.add(pos[1]-character[1].width/2);
  }
  bulletPos.add(newBullet);
}

void drawBullet(){
  for(int i = 0; i < bulletPos.size(); i++){
    imageMode(CENTER);
    image(bullet, bulletPos.get(i).get(0), bulletPos.get(i).get(1));
    bulletPos.get(i).set(0, bulletPos.get(i).get(0)+30);
    if (bulletPos.get(i).get(0)-bullet.width/2 > width || (bulletPos.get(i).get(0)+bullet.width/2>groundPos[nextGround][0] && bulletPos.get(i).get(1) > topOfNextGrass && groundPos[nextGround][0] > 0)) bulletPos.remove(i);
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
    if (int(saveData[1]) == 0) justFired = true;
    bulletsRemaining--;
    if (bulletsRemaining == 0) reloadStart = millis();
    addBullet();
  } else if (!mousePressed
  && recoil == 0) {
    justFired = false;
  }
  if (recoil >= 10) {
    vRecoil*=-1;
  }
  if (recoil != 0 && pos[0] > 0 && !reloading) {
    recoil+=vRecoil;
    rotate(-PI/2);
  } else if(pos[0]>0) rotate(rotation);
  if (int(saveData[1]) == 0) {
    image(glock[0], 5, character[1].height);
    image(glock[1], 2+glock[0].width/2, character[1].height-recoil);
  }
  image(character[1], 0, character[1].height/2);
  rectMode(CENTER);
  popMatrix();
  if (bulletsRemaining == 0 && millis()-reloadStart >= reloadTime[int(saveData[1])]) {
    bulletsRemaining = 12;
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
  textAlign(CORNER);
  text("Bullets remaining: " + bulletsRemaining, 48, 48);
  text(int(distTravelled)+" m", 100, 100);
}

void drawChar() {
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= pos[0]-character[0].width/1.2 || trail.get(trail.size()-1).get(1) > pos[1]+character[0].height/1.2 || trail.get(trail.size()-1).get(1)+character[0].height/1.2 < pos[1]) addTrail();
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
  image(character[2], 0, character[1].height/2);
  rotate(-rotation*2);
  image(character[2], 0, character[1].height/2);
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

void updateEnemies(){
  for (int i = 0; i < enemies.size(); i++){
    imageMode(CENTER);
  }
}

void drawUpdateObstacle(){
  for(int i = 0; i < obstacles.size(); i++){
    imageMode(CENTER);
    image(obstacleImages[int(obstacles.get(i).get(2))], obstacles.get(i).get(0), obstacles.get(i).get(1)-obstacleImages[int(obstacles.get(i).get(2))].height/2);
    obstacles.get(i).set(0, obstacles.get(i).get(0)-(int(speed)/3+5));
    if (obstacles.get(i).get(0)+obstacleImages[int(obstacles.get(i).get(2))].height/2 <= 0) obstacles.remove(i);
  }
}

void health(){
  health=100;
  if(colliding){
    health-=25;
  }
  fill(255,0,0);
  rect(600,50,100,20);
}

void game() {
  imageMode(CENTER);
  image(background[2], width/2, height/2);
  nextHeight = random(-75, 75);
  imageMode(CORNER);
  for (int i = 0; i < skyX.length; i++){
    image(background[1], skyX[i], 0);
    if (!firstTime) skyX[i]-=int(speed)/4+5;
    if (skyX[i] <= -background[1].width){
      if (i == 0) next = 1;
      else next = 0;
      if (skyX[next] < 0) skyX[i] = width;
      else skyX[i] = skyX[next]+background[1].width;
    }
  }
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
        newObstacle.add(75.0);
        obstacles.add(newObstacle);
      }
      int numOfEnemies = int(random(0, 5));
      for (int a = 0; a < numOfEnemies; a++){
        ArrayList<Float> newEnemy = new ArrayList<Float>();
        newEnemy.add(random(groundPos[i][0]+cyborg.width, groundPos[i][0]+background[0].width-cyborg.width));
        newEnemy.add(groundPos[i][1]+34);
        newEnemy.add(100.0);
        
      }
    }
    if (!firstTime) groundPos[i][0]-=int(speed)/3+5;
  }
  drawUpdateObstacle();
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
    text("Press W to jump, Space to glide,", width/2, height/2-80);
    text("and Left Click to shoot.", width/2, height/2-20);
    text("Go the furthest distance without dying!", width/2, height/2+40);
    text("Press anywhere to continue", width/2, height/2+150);
    if (clicked) firstTime = false;
  }
  if(pos[0]<=0){
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
      //saveStrings("saveGame.txt", saveData);
    }
  }
  else if (!firstTime) charInfo();
  if (justJumped) justJumped = false;
}

void credits() {
  background(0);
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

void shop(){
  background(0);
  fill(255);
  text("Shop",600,100);
  rect(width/2,200,900,80);
  rect(width/2,300,900,80);
  rect(width/2,400,900,80);
  rect(width/2,500,900,80);
  text("Press anywhere to return to main menu",width/2,height-100);
  fill(0);
  textSize(48);
  text("Gun",width/4,200);
  text("Jetpack",width/4,300);
  text("Health",width/4,400);
  text("Bullet Count",width/4+30,500);
  rect(width*3/4,200,100,60);
  rect(width*3/4,300,100,60);
  rect(width*3/4,400,100,60);
  rect(width*3/4,500,100,60);
  fill(255);
  textSize(20);
  text("upgrade",width*3/4,200);
  text("upgrade",width*3/4,300);
  text("upgrade",width*3/4,400);
  text("upgrade",width*3/4,500);
  textSize(48);
  if(clicked){
    currentScene = 0;
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
