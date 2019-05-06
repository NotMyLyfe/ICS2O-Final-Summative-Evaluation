/*ICS2O Final Summative Evaluation
By Gordon Lin and Daniel Weng
*/

int currentScene = 0;

PFont[] regular = new PFont[3];
PFont[] light = new PFont[3];
PFont[] xLight = new PFont[3];
PFont[] thin = new PFont[3];

void initFont(){
  for (int i = 0; i < regular.length; i++){
    regular[i] = createFont("Font/Montserrat-Regular.ttf", (i+1)*48);
    light[i] = createFont("Font/Montserrat-Light.ttf", (i+1)*48);
    xLight[i] = createFont("Font/Montserrat-LightItalic.ttf", (i+1)*48);
    thin[i] = createFont("Font/Montserrat-Thin.ttf", (i+1)*48);
  }
}

void setup(){
  size(1280, 720);
  initFont();
}

void mainMenu(){
  background(0);
  fill(255);
  textFont(regular[1], 96);
  textAlign(CENTER, CENTER);
  text("Ultimate Dash", width/2, 100);
  
  textFont(light[0], 48);
  rectMode(CENTER);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60 && mouseY < height/2+20){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2-20, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2-60 && mouseY < height/2+20){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Play Game", width/2, height/2-25);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+40 && mouseY < height/2+120){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+80, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+40 && mouseY < height/2+120){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Load Game", width/2, height/2+75);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+140 && mouseY < height/2+220){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+180, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+140 && mouseY < height/2+220){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Credits", width/2, height/2+175);
  
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+240 && mouseY < height/2+320){
    fill(0);
  }
  else{
    fill(255);
  }
  rect(width/2, height/2+280, 300, 80);
  if (mouseX > width/2-150 && mouseX < width/2+150 && mouseY > height/2+240 && mouseY < height/2+320){
    fill(255);
  }
  else{
    fill(0);
  }
  text("Exit", width/2, height/2+275);
  
}

void draw(){
  if (currentScene == 0) mainMenu();
}
