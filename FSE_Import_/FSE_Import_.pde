PImage square;
PImage back;

int JUMPPOWER=-10;
float gravity=0.5;

float px=0.0;
float py=0.0;
float vy=0;
float angle=0;

boolean moveLeft=false;
boolean moveRight=false;

void movePlayer(){
  if(moveRight){
    px+=10;;
  }
  if(moveLeft){
    px-=10;;
  }
  py+=vy;//moving the player up/down
  if (py>450){
    py=450;//keep the player on the ground
    vy=0;//stop falling
  }
  
  vy+=gravity;//apply gravity
}

void keyPressed(){
  if (key==32 && py==450){//only jump if on ground
    vy=JUMPPOWER;//jumping power
  }
}//end keyPressed

void setup(){
  size(800,600);
  square=loadImage("white-small-square_25ab.png");
  back=loadImage("Wiki-background.png");
}

void draw(){
  background(255);
  movePlayer();
  for(int i=0;i<99999;i+=600){
    //rotate(angle);
    // angle+=0.1;
    image(back,px+i,0);
    rect(0,565,800,565);
  }
  px-=10;
  image(square,200,py);
  fill(0,255,0);
}
