/*ICS2O Final Summative Evaluation
 By Gordon Lin and Daniel Weng
 */

int currentScene = 0;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

String[] saveData = {"0", "0"}; //0th value: past distance, 1st value: gun type

float loadError = 0;

float time = 0;

PImage[] character = new PImage[3];
PImage[] glock = new PImage[2];

int[] reloadTime = {4000};

int JUMPPOWER=-12;
float gravity=0.6;
boolean jump=false;

float pos[] = {500.0, 0.0};

float vy=0;
float angle=0;

int[] bullets = {12};
int bulletsRemaining = 0;

ArrayList<ArrayList<Float>> trail = new ArrayList<ArrayList<Float>>();

float distTravelled=0;
float speed=1;
float speedUp=1/60;

PImage background[] = new PImage[3];

float[][] groundPos = {{0, height+400}, {1280, height+400}};

float topOfGrass = 0;
float topOfNextGrass = 0;
int nextGround = 0;
int current = 0;
float bottomOfPlayer = 0;
boolean onGround = true;
boolean colliding = false;

void movePlayer() {
  bottomOfPlayer = pos[1]+character[0].height/3+character[2].height;
  pos[1]+=vy;//moving the player up/down
  for (int i = 0; i < 2; i++) {
    //println(groundPos[i][0] + background[0].width > pos[0] && pos[0] > groundPos[i][0]);
    if (groundPos[i][0] + background[0].width > pos[0] && pos[0] > groundPos[i][0]) {
      topOfGrass = groundPos[i][1]+49;
      if (i == 0) nextGround = 1;
      else nextGround = 0;
      current = i;
    }
  }
  topOfNextGrass = groundPos[nextGround][1]+49;
  float nextX = groundPos[nextGround][0] - int(speed)*5+character[0].width/2;
  float heightDif = bottomOfPlayer - topOfNextGrass;
  println(heightDif + " " + nextX);
  if (heightDif > 10 && nextX<=pos[0]+character[0].width && nextX >= pos[0]-character[0].width){
    pos[0]-=speed*5;
    onGround = false;
    colliding = true;
  }
  else colliding = false;
  if (onGround && heightDif < 0 && nextX <= pos[0] && !colliding){
    onGround = false;
    pos[1]--;
    pos[0]++;
    vy = 0;
    pos[0]--;
  }
  if(!colliding && pos[0]<500){
    pos[0]++;
  }
  if (topOfGrass <= bottomOfPlayer && !onGround && vy > 0) {
    onGround = true;
    vy=0;//stop falling
  }
  if (onGround && !colliding) pos[1]=topOfGrass-(character[0].height/3+character[2].height);
  else vy+=gravity;//apply gravity
  //println(pos[1] + character[0].height/3+character[2].height, topOfGrass+49);
}


void initFont() {
  for (int i = 0; i < regular.length; i++) {
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48);
    xLight[i] = createFont("Font/Montserrat-LightItalic.ttf", (i+1)*48);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48);
  }
}

void initImgs() {
  character[0] = loadImage("Imgs/Character Body.png");
  character[1] = loadImage("Imgs/Character Arm.png");
  character[2] = loadImage("Imgs/Character Leg.png");
  for (int i = 0; i < 3; i++) {
    character[i].resize(character[i].width*3/4, character[i].height*3/4);
  }
  character[1].resize(character[1].width*3/4, character[1].height*3/4);
  glock[0] = loadImage("Imgs/Glock Shell.png");
  glock[1] = loadImage("Imgs/Glock Side.png");
  background[0] = loadImage("Imgs/Grass.png");
  background[1] = loadImage("Imgs/Clouds.png");
  background[2] = loadImage("Imgs/Blue Sky.png");
  background[0].resize(width, background[0].height*2/3);
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

boolean[] buttons = {false, false, false};

void mainMenu() {
  background(0);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("Ultimate Dash", width/2, 100);

  textFont(light[0], 48);
  rectMode(CENTER);
  for (int i = 0; i < 3; i++){
    if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60+i*100 && mouseY < height/2+20+i*100) buttons[i] = true;
    else buttons[i] = false;
  }
  if (buttons[0]) {
    fill(0);
    if (mousePressed){
      currentScene = 2;
      bulletsRemaining = bullets[int(saveData[1])]+1;
    }
  } else {
    fill(255);
  }
  rect(width/2, height/2-20, 300, 80);
  if (buttons[0]) {
    fill(255);
  } else {
    fill(0);
  }
  text("Play Game", width/2, height/2-25);

  if (buttons[1]) {
    fill(0);
  } else {
    fill(255);
  }
  rect(width/2, height/2+80, 300, 80);
  if (buttons[1]) {
    fill(255);
    if (mousePressed) currentScene = 1;
  } else {
    fill(0);
  }
  text("Credits", width/2, height/2+75);

  if (buttons[2]) {
    fill(0);
    if (mousePressed) exit();
  } else {
    fill(255);
  }
  rect(width/2, height/2+180, 300, 80);
  if (buttons[2]) {
    fill(255);
  } else {
    fill(0);
  }
  text("Exit", width/2, height/2+175);
}

boolean justJumped = false;

void keyPressed() {
  if (key=='w' && onGround && !justJumped) {//only jump if on ground
    vy=JUMPPOWER;//jumping power
    onGround = false;
    justJumped = true;
  }
}//end keyPressed

void keyReleased() {
  if (key==32) {
    jump=false;
  }
  if (key == 'w'){
    justJumped = false;
  }
}


float rotation = 0;
float vR = radians(8.5);

float recoil = 0;
float vRecoil = 0;

void addTrail() {

  tint(255, 100);
  ArrayList<Float> newTrail = new ArrayList<Float>();
  newTrail.add(pos[0]-20);
  newTrail.add(pos[1]);
  newTrail.add(rotation);
  newTrail.add(recoil);
  trail.add(newTrail);
}

void jetpack() {
  if (keyPressed && key==32) {
    jump=true;
    if (vy>=0 && jump) {
      vy=2*gravity;
    }
  }
}

void updateTrail() {
  for (int i = 0; i < trail.size(); i++) {
    tint(255, (trail.get(i).get(0) / pos[0])*200);
    pushMatrix();
    translate(trail.get(i).get(0), trail.get(i).get(1)+character[0].height/3);
    rotate(trail.get(i).get(2));
    image(character[2], 0, character[1].height/2);
    rotate(-trail.get(i).get(2)*2);
    image(character[2], 0, character[1].height/2);
    popMatrix();
    image(character[0], trail.get(i).get(0), trail.get(i).get(1));
    if (trail.get(i).get(3)==0) {
      pushMatrix();
      translate(trail.get(i).get(0), trail.get(i).get(1));
      rotate(trail.get(i).get(2));
      if (int(saveData[1]) == 0) {
        image(glock[0], 5, character[1].height);
        image(glock[1], 2+glock[0].width/2, character[1].height-trail.get(i).get(3));
      }
      image(character[1], 0, character[1].height/2);
      popMatrix();
    } else {
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
    trail.get(i).set(0, trail.get(i).get(0)-5*int(speed));
    if (trail.get(i).get(0)+character[0].width < 0 || trail.get(i).get(0)/pos[0]*200 < 10) {
      trail.remove(i);
    }
  }
}

boolean justFired = false;
float reloadStart = 0;

void addBullet(){
}

void drawArms() {
  rectMode(CENTER);
  pushMatrix();
  translate(pos[0], pos[1]);
  if (mousePressed && !justFired && bulletsRemaining > 0) {
    vRecoil = 2;
    recoil=2;
    justFired = true;
    bulletsRemaining--;
    if (bulletsRemaining == 0) reloadStart = millis();
  } else if (!mousePressed && recoil == 0) {
    justFired = false;
  }
  if (recoil >= 10) {
    vRecoil*=-1;
  }
  if (recoil != 0) {
    recoil+=vRecoil;
    rotate(-PI/2);
  } else rotate(rotation);
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
  }
}

void charInfo() {
  fill(0);
  textFont(regular[0], 48);
  textAlign(CORNER);
  text("Bullets remaining: " + bulletsRemaining, 48, 48);
}

void drawChar() {
  if (trail.size() == 0 || trail.get(trail.size()-1).get(0) <= pos[0]-character[0].width/1.2 || trail.get(trail.size()-1).get(1) > pos[1]+character[0].height/1.2 || trail.get(trail.size()-1).get(1)+character[0].height/1.2 < pos[1]) addTrail();
  imageMode(CENTER);
  updateTrail();
  tint(255, 255);
  fill(0, 255, 0);
  if (rotation >= PI/4 || rotation <= -PI/4) vR*=-1;
  rotation+=vR;
  pushMatrix();
  translate(pos[0], pos[1]+character[0].height/3);
  rotate(rotation);
  image(character[2], 0, character[1].height/2);
  rotate(-rotation*2);
  image(character[2], 0, character[1].height/2);
  popMatrix();
  image(character[0], pos[0], pos[1]);
  drawArms();
}
float nextHeight;
int next;
float[] skyX = {0, 1280};
void game() {
  jetpack();
  imageMode(CENTER);
  image(background[2], width/2, height/2);
  nextHeight = random(-75, 75);
  for (int i = 0; i < groundPos.length; i++) {
    imageMode(CORNER);
    image(background[1], skyX[i], 0);
    skyX[i]-=int(speed)*2;
    if (skyX[i] <= -background[1].width){
      if (i == 0) next = 1;
      else next = 0;
      skyX[i] = skyX[next]+background[1].width;
    }
    image(background[0], groundPos[i][0], groundPos[i][1]);
    if (groundPos[i][0] <= -background[0].width) {
      if (i == 0) next = 1;
      else next = 0;
      if (groundPos[next][1]+nextHeight > height-50) {
        groundPos[i][1] = height-50;
        println("too low");
      }
      else if (groundPos[next][1]+nextHeight < height-400){
        groundPos[i][1] = height-400;
        println("too high");
      }
      else groundPos[i][1] = groundPos[next][1]+nextHeight;
      groundPos[i][0] = groundPos[next][0]+background[0].width;
    }
    groundPos[i][0]-=int(speed)*5;
  }
  movePlayer();
  distTravelled=distTravelled+(1*0.04*speed);
  text(int(distTravelled)+" m", 100, 100);
  speed=speed+speedUp/60;
  drawChar();
  charInfo();
  if(pos[0]<-60){
    speed=0;
    textSize(100);
    text("GAME OVER",300,300);
    textSize(48);
    text("Distance: "+int(distTravelled),300,350);
  }
}

void credits() {
}

void draw() {
  if (currentScene == 0) mainMenu();
  else if (currentScene == 1) credits();
  else if (currentScene == 2) game();
}
