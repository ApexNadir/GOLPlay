//Ross Metcalfe 2019

//Made in one day.
//Conways game of life implementation.
//Birth and Survive rules can be changed by pressing numbers on the keyboard when the mouse is on the left and right hand side of the screen.
//Try mode 3 with rule B3/S2345
//Try B1/S123456789
//Optimised somewhat over a naive implementation by keeping track of changed (active) cells and only checking the surrounding 8 cells for changes.
//Inactive areas can be ignored this way.
//Cell changes are drawn instead of drawing the entire grid each frame.
//Both these optimisations improved large grid performance significantly
//Instead of O(N) where N is the area of the grid, the time complexity scales with number of active cells which is dynamic


//Sorry about the messy code. I wasn't expecting to upload to GitHub, or even for the program to be this big

//Start from the setup() and draw() functions and go from there.



boolean wrapAround;
boolean[][][] cells;
boolean mouseDown;
boolean RmouseDown;
boolean paused;
boolean oneFrame;
boolean help;
boolean grid;
int step;
PGraphics cellsIm;
PGraphics activeCellsIm;
int mode;
boolean[] born;
boolean[] stay;
class CellPos {
  int x, y;
  CellPos(int x0, int y0) {
    x=x0;
    y=y0;
  }
  void update() {
    updateCell(x, y,true);
  }
  boolean equals(CellPos cp2) {
    return x==cp2.x&&y==cp2.y;
  }
  void drawCell() {
    return;
    //rect(x*cellSize, y*cellSize, cellSize, cellSize);
  }
}


void drawAliveCell(int x, int y) {
  switch(mode){
    case 0:
      cellsIm.fill(0);
    break;
    case 1:
      cellsIm.fill(255);
    break;
    case 2:
      cellsIm.fill((0.5*step)%255,255,255);
    break;
  }
  cellsIm.rect(x*cellSize, y*cellSize, cellSize, cellSize);
}
void drawDeadCell(int x, int y) {
  
  switch(mode){
    case 0:
      cellsIm.fill(255);
    break;
    case 1:
      cellsIm.fill(0);
    break;
    case 2:
      cellsIm.fill(0);
    break;
  }
  
  
  cellsIm.rect(x*cellSize, y*cellSize, cellSize, cellSize);
}
void debugDrawCell(int x, int y){
  cellsIm.fill(0,255,0,200);
  cellsIm.rect(x*cellSize, y*cellSize, cellSize, cellSize);
  cellsIm.fill(0);
}
void debugDrawActiveCell(boolean active,int x, int y){
  activeCellsIm.beginDraw();
  //println("activedraw",x,y);
  activeCellsIm.fill(255-int(active)*255,int(active)*255,0,150);
  activeCellsIm.rect(x*cellSize, y*cellSize, cellSize, cellSize);
  activeCellsIm.endDraw();
}
ArrayList<CellPos> activeCells;
ArrayList<CellPos> activeCellsNext;
int cellSize=1;
int w, h;
int cellCalls;
int frameInterval=1;
int perFrame=1;
void setup() {
  grid=false;
  help=true;
  mode=0;
  step=0;
  oneFrame=false;
  //fullScreen(P2D);
  size(1600,900);
  mouseDown=false;
  RmouseDown=false;
  paused=false;
  wrapAround = true;
  w=ceil(width/cellSize);
  h=ceil(height/cellSize);
  cells = new boolean[w][h][4];//0 - visual, 1 - previous state, 2 - checked this update, 3 - active cell
  activeCells = new ArrayList<CellPos>();
  activeCellsNext = new ArrayList<CellPos>();
  cellsIm = createGraphics(width,height);
  activeCellsIm = createGraphics(width,height);
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      cells[x][y][0]=false;
      cells[x][y][1]=false;
      cells[x][y][2]=false;
      cells[x][y][3]=false;
    }
  }
  drawModeSet();
  activeCellsIm.beginDraw();
  activeCellsIm.noStroke();
  //activeCellsIm.background(100);
  activeCellsIm.endDraw();
  noStroke(); 
  background(255);
  if(grid){drawGridLines();}
  born = new boolean[10];
  stay = new boolean[10];
  born[3]=true;
  stay[2]=true;
  stay[3]=true;
  textAlign(LEFT,TOP);
}

void changedCellSize(){
  w=ceil(width/cellSize);
  h=ceil(height/cellSize);
  cells = new boolean[w][h][4];//0 - visual, 1 - previous state, 2 - checked this update, 3 - active cell
  activeCells = new ArrayList<CellPos>();
  activeCellsNext = new ArrayList<CellPos>();
  cellsIm = createGraphics(width,height);
  activeCellsIm = createGraphics(width,height);
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      cells[x][y][0]=false;
      cells[x][y][1]=false;
      cells[x][y][2]=false;
      cells[x][y][3]=false;
    }
  }
  drawModeSet();
  //activeCellsIm.beginDraw();
  //activeCellsIm.noStroke();
  //activeCellsIm.background(100);
  //activeCellsIm.endDraw();
  noStroke(); 
  background(255);
  if(grid){drawGridLines();}
  //born = new boolean[10];
  //stay = new boolean[10];
  //born[3]=true;
  //stay[2]=true;
  //stay[3]=true;
  textAlign(LEFT,TOP);
}


void drawModeSet(){
  
  switch(mode){
    case 0: //white background black alive cells
      cellsIm.beginDraw();
      cellsIm.colorMode(RGB);
      cellsIm.noStroke();
      cellsIm.background(255);
      cellsIm.endDraw();
    break;
    case 1: //black background white alive cells
      cellsIm.beginDraw();
      cellsIm.colorMode(RGB);
      cellsIm.noStroke();
      cellsIm.background(0);
      cellsIm.endDraw();
    break;
    case 2: //hue over step with black back
      cellsIm.beginDraw();
      cellsIm.colorMode(HSB);
      cellsIm.noStroke();
      cellsIm.background(0);
      cellsIm.endDraw();
    break;
  }
  
  if(grid){drawGridLines();}
  
  cellsIm.beginDraw();
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      if(cells[x][y][0]){
        drawAliveCell(x,y);
      }else{
        drawDeadCell(x,y);
      }
    }
  }
  cellsIm.endDraw();
}
void changeCellState(int x, int y,boolean newState){
  activeCells.add(new CellPos(x, y));
  cells[x][y][0]=newState;
  cells[x][y][1]=newState;
  cells[x][y][3]=true;
  if(newState){
    drawAliveCell(x,y);
  }else{
    drawDeadCell(x,y);
  }
}
void draw() {
  cellsIm.beginDraw();
  if (mouseDown||RmouseDown) {
    float dM = dist(mouseX, mouseY, pmouseX, pmouseY);
    int idM = max(1, ceil(2*dM/cellSize));
    float dx = mouseX-pmouseX;
    float dy = mouseY-pmouseY;
    
    int radius = round(20f/cellSize);
    if(RmouseDown){idM=max(1,min(idM,ceil(dM/(cellSize*radius))));}
    
    dx/=idM;
    dy/=idM;
    float x, y;
    x=pmouseX-cellSize/2;
    y=pmouseY-cellSize/2;
    for (int i=0; i<idM; i++) {
      int mx, my;
      mx = round(x/cellSize);
      my = round(y/cellSize);
      if (mx>=0&&mx<w&&my>=0&&my<h) {
        if(mouseDown){
          changeCellState(mx,my,true);
        }else{
          for(int c=mx-radius;c<mx+radius;c++){
            if(c<0){continue;}
            if(c>=w){break;}
            for(int r=my-radius;r<my+radius;r++){
              if(r<0){continue;}
              if(r>=h){break;}
              if(dist(c,r,mx,my)<radius){
                changeCellState(c,r,false);
              }
            }
          }
        }
      }
      x+=dx;
      y+=dy;
    }
  }
  
  
  if ((frameCount%frameInterval==0&&!paused)||oneFrame) {
    if (oneFrame) {
      oneFrame=false;
    }
    for (int i=0; i<perFrame; i++) {
      updateCells();
      //flipCells();
    }
  }
  
  cellsIm.endDraw();
  drawCells();
  //image(activeCellsIm,100,0);
  if(help){
    drawHelp();
  }
}


void drawHelp(){
  fill(50, 200);
  rect(0, 58, 210, 174);
  int textHeight=60;
  fill(0,200,0);
  text("H - Opens and Closes this help menu", 4, textHeight);
  textHeight+=14;
  text("Space - Pauses the simulation", 4, textHeight);
  textHeight+=14;
  text("R - Randomly places living cells", 4, textHeight);
  textHeight+=14;
  text("C - Clears the simulation", 4, textHeight);
  textHeight+=14;
  text("- - Decreases the Sim Speed", 4, textHeight);
  textHeight+=14;
  text("+ - Increases the Sim Speed", 4, textHeight);
  textHeight+=14;
  text("F - Simulates one step", 4, textHeight);
  textHeight+=14;
  text("M - Changes visual mode", 4, textHeight);
  textHeight+=14;
  text("G - Toggles Grid", 4, textHeight);
  textHeight+=14;
  text("[ - Decrease Cell Size", 4, textHeight);
  textHeight+=14;
  text("] - Increase Cell Size", 4, textHeight);
  textHeight+=14;
  text("W - Toggle Wraparound", 4, textHeight);
  
  textAlign(CENTER,BOTTOM);
  String side;
  if(mouseX<width/2){
    side = "Birth";
  }else{
    side = "Survival";
  }
  fill(50,200);
  rect(0,height-28,width,28);
  fill(0,200,0);
  text("If you were to press a digit now, the digit would be added/removed from the " + side + " rules.",width/2,height-14);
  text("Birth and Survive rules can be changed by pressing numbers on the keyboard when the mouse is on the left and right hand side of the screen.",width/2,height);
  String stayStr="S: ";
  String bornStr="B: ";
  for(int i=0;i<10;i++){
    if(born[i]){
      bornStr+=i + ",";
    }
    if(stay[i]){
      stayStr+=i + ",";
    }
  }
  bornStr = bornStr.substring(0,bornStr.length()-1);
  stayStr = stayStr.substring(0,stayStr.length()-1);
  textSize(20);
  textAlign(LEFT,BOTTOM);
  text(bornStr,4,height);
  textAlign(RIGHT,BOTTOM);
  text(stayStr,width-4,height);
  textAlign(LEFT,TOP);
  
  textSize(11);
  
  if(paused){
    fill(255,0,0);
    text("Paused",100,16);
  }
  fill(50, 200);
  rect(0, 0, 60, 54);
  fill(0, 255, 0);
  text(cellCalls, 3, 2);
  text(frameRate, 0, 14);
  text(frameInterval + " - " + perFrame, 3, 26);
  text(cellSize, 3, 38);
  fill(0);
  
}
void updateCells() {
  //activeCellsIm.beginDraw();
  //activeCellsIm.clear();
  //activeCellsIm.endDraw();
  cellCalls=0;
  step++;
  println("Step: ", step);
  //flip activeCellsArrays
  /*
  for (CellPos cp : activeCells) {
    println("ActiveList: ",cp.x,cp.y);
  }*/
  for (CellPos cp : activeCells) {
    cp.update();
  }
  println("Cell Calls: ", cellCalls);
  
  for (CellPos cp : activeCells) {
    flipLocal(cp.x,cp.y);
  }
  for (CellPos cp : activeCellsNext) {
    flipLocal(cp.x,cp.y);
  }
  flipCells();

  ArrayList<CellPos> temp;
  temp = activeCells;
  activeCells =activeCellsNext;
  activeCellsNext = temp;
  activeCellsNext.clear();
  
  
  
}


void updateCell(int x, int y,boolean active) {
  if(cells[x][y][2]){return;}
  cells[x][y][2]=true;
  cellCalls++;
  int aliveNear=0;
  for (int i=x-1; i<=x+1; i++) {
    int ti, tj;
    ti=i;
    if (ti<0) {
      if (wrapAround) {
        ti+=w;
      } else {
        continue;
      }
    }
    if (ti>=w) {
      if (wrapAround) {
        ti-=w;
      } else {
        continue;
      }
    }
    for (int j=y-1; j<=y+1; j++) {
      tj=j;
      if (tj<0) {
        if (wrapAround) {
          tj+=h;
        } else {
          continue;
        }
      }
      if (tj>=h) {
        if (wrapAround) {
          tj-=h;
        } else {
          continue;
        }
      }
      if (i==x&&j==y) {
        continue;
      }
      if (cells[ti][tj][1]) {
        aliveNear++;
        //println(ti,tj,"near");
      }
      if (active && !cells[ti][tj][2] && !cells[ti][tj][3]) { // if we are active, the second cell hasnt been called already, and the second cell is not active
        updateCell(ti, tj,false);
        cells[ti][tj][2]=true;
      }
    }
  }
  /*
  if(active){
    print("Active ");
    debugDrawActiveCell(true,x,y);
  }else{
    debugDrawActiveCell(false,x,y);
  }*/
  //println("Cell: ", x, y, aliveNear);
  if (cells[x][y][1]) {
    //alive
    if (stay[aliveNear]) {
      cells[x][y][0]=true;
      cells[x][y][3]=false;
    } else {
      //println("active because died",x,y);
      activeCellsNext.add(new CellPos(x, y));
      cells[x][y][0]=false;
      cells[x][y][3]=true;
      drawDeadCell(x,y);
      //println("died ", x, y);
    }
  } else {
    //dead
    if (born[aliveNear]) {
      //println("active because born",x,y);
      activeCellsNext.add(new CellPos(x, y));
      drawAliveCell(x,y);
      cells[x][y][0]=true;
      cells[x][y][3]=true;
      //println("born ", x, y);
    }else{
      cells[x][y][3]=false;
    }
  }
  if(cells[x][y][0]){
    //activeCellsNext.add(new CellPos(x, y));
  }
}

void flipLocal(int x, int y){
  
  for (int i=x-1; i<=x+1; i++) {
    int ti, tj;
    ti=i;
    if (ti<0) {
      if (wrapAround) {
        ti+=w;
      } else {
        continue;
      }
    }
    if (ti>=w) {
      if (wrapAround) {
        ti-=w;
      } else {
        continue;
      }
    }
    for (int j=y-1; j<=y+1; j++) {
      tj=j;
      if (tj<0) {
        if (wrapAround) {
          tj+=h;
        } else {
          continue;
        }
      }
      if (tj>=h) {
        if (wrapAround) {
          tj-=h;
        } else {
          continue;
        }
      }
      if (i==x&&j==y) {
        continue;
      }
      cells[ti][tj][1]=cells[ti][tj][0];
      cells[ti][tj][2]=false;
    }
  }
}

void flipCells() {
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      cells[x][y][1]=cells[x][y][0];
      cells[x][y][2]=false;
    }
  }
}

void drawCells() {
  image(cellsIm,0,0);
}

void randomCells(float density) {
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      if (random(0, 1)<density) {
        cells[x][y][1]=true;
        activeCells.add(new CellPos(x, y));
        cells[x][y][3]=true;
        drawAliveCell(x,y);
      }
    }
  }
}

void clearCells(){
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      cells[x][y][0]=false;
      cells[x][y][1]=false;
      cells[x][y][2]=false;
      cells[x][y][3]=false;
    }
  }
  
  
  activeCells.clear();
  switch(mode){
    case 0: //white background black alive cells
      cellsIm.beginDraw();
      cellsIm.colorMode(RGB);
      cellsIm.noStroke();
      cellsIm.background(255);
      cellsIm.endDraw();
    break;
    case 1: //black background white alive cells
      cellsIm.beginDraw();
      cellsIm.colorMode(RGB);
      cellsIm.noStroke();
      cellsIm.background(0);
      cellsIm.endDraw();
    break;
    case 2: //hue over step with black back
      cellsIm.beginDraw();
      cellsIm.colorMode(HSB);
      cellsIm.noStroke();
      cellsIm.background(0);
      cellsIm.endDraw();
    break;
  }
  
  if(grid){drawGridLines();}
  //noStroke();
}

void drawGridLines() {
  cellsIm.beginDraw();
  if(cellSize<2){
    cellsIm.noStroke();
    cellsIm.endDraw();
    return;
  }
  if(mode==0){
    cellsIm.stroke(0);
  }else{
    cellsIm.stroke(255);
  }
  for (int x=0; x<w; x++) {
    cellsIm.line(x*cellSize, 0, x*cellSize, height);
  }
  for (int y=0; y<h; y++) {
    cellsIm.line(0, y*cellSize, width, y*cellSize);
  }
  
  cellsIm.endDraw();
}

void mousePressed() {
  if (mouseButton==LEFT) {
    mouseDown=true;
  }else if (mouseButton==RIGHT){
    RmouseDown=true;
  }
}

void mouseReleased() {
  if (mouseButton==LEFT) {
    mouseDown=false;
  }else if (mouseButton==RIGHT){
    RmouseDown=false;
  }
}



void keyPressed() {
  int i=key-48;
  if(i>=0&&i<10){
    println(i);
    if(mouseX<width/2){
      born[i]=!born[i];
    }else{
      stay[i]=!stay[i];
    }
    activateAllCells();
  }
  if (key==' ') {
    paused=!paused;
  }
  if (key=='m') {
    mode++;
    if(mode>2){
      mode=0;
    }
    drawModeSet();
  }
  if (key=='f') {
    oneFrame=true;
  }
  if (key=='g') {
    grid=!grid;
    if(grid){
      println("grid");
      drawGridLines();
    }else{
      println("gridoff");
      cellsIm.beginDraw();
      cellsIm.noStroke();
      cellsIm.endDraw();
      drawModeSet();
    }
  }
  if (key=='w') {
    wrapAround=!wrapAround;
  }
  if (key=='[') {
    if(cellSize>1){
      cellSize--;
      changedCellSize();
    }
  }
  if (key==']') {
    cellSize++;
    changedCellSize();
  }
  if (key=='h') {
    help=!help;
  }
  if (key=='r') {
    randomCells(0.5);
  }
  if (key=='c') {
    clearCells();
  }
  if (key=='=') {
    frameInterval--;
    if (frameInterval<1) {
      frameInterval=1;
      perFrame++;
    }
    frameInterval =max(1, frameInterval);
  }
  if (key=='-') {
    if (perFrame>1) {
      perFrame--;
    } else {
      frameInterval++;
      frameInterval =min(60, frameInterval);
    }
  }
}

void activateAllCells(){
  for (int x=0; x<w; x++) {
    for (int y=0; y<h; y++) {
      //if(cells[x][y][0]){
        activeCells.add(new CellPos(x,y));
      //}
    }
  }
}