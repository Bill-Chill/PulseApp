int[] pulse1 = {50, 50};
int[] pulse2 = {50, 320};
int area_width = 170;  
int area_height = 35; 
int area_space = 250;
int gWidth = 780; 
int gHeight = 550;

int batchPulseType = 0; 

ArrayList pareaList;  
ArrayList bloodList;
int areaSelectIdx = -1;
int pulseNumber = 30;

PFont fontStar;
PFont fontArrow;
PFont fontWu;
PFont fontTongueText; 

int currentTongueType = 0; 
float textX = 580; 
float textY = 245; 
boolean draggingText = false;
float dragOffsetX = 0;
float dragOffsetY = 0;
String currentTongueText = "";

class PulseArea {
  int x, y, w, h;
  int idx;
}

class BloodType {
  int x, y, w, h;
  int idx;
  int type; 
  int group_size;
  int width_type; 
}

void setup() {
  size(780, 550);
  pareaList = new ArrayList();
  bloodList = new ArrayList();
  for(int i=0; i<pulseNumber; i++) {
    bloodList.add(new ArrayList());              
  }
   
  strokeWeight(10);
  fontStar = createFont("Microsoft JhengHei, PingFang TC, sans-serif", 24);
  fontArrow = createFont("PingFang TC, Microsoft JhengHei, sans-serif", 28);
  fontWu = createFont("PingFang TC, Microsoft JhengHei, sans-serif", 20);
  fontTongueText = createFont("PingFang TC, Microsoft JhengHei, sans-serif", 18);

  initPulseArea();
  bgDraw();
}

void setBatchMode(int type) {
  batchPulseType = type;
  if (batchPulseType != 0) {
    areaSelectIdx = -1;
    mouseMoved();
  }
}

void setTongueType(int type) {
  currentTongueType = type;
  mouseMoved(); 
}

void setTongueNote(String txt) {
  currentTongueText = txt;
  mouseMoved(); 
}

void draw() {
}

void initPulseArea() { 
  for(int i=0; i<6; i++) {
    for(int j=0; j<5; j++) {            
      PulseArea parea = new PulseArea();
      int idx = i*5+j;
      int x_plus = 0; 
      int y_plus = 0;
      if(i<3) {             
        x_plus = pulse1[0] + (area_space*(i%3));
        y_plus = pulse1[1] + (area_height*j) + 2; 
      } else {    
        x_plus = pulse2[0] + (area_space*(i%3));
        y_plus = pulse2[1] + (area_height*j) + 2; 
      }
      parea.x = x_plus;    
      parea.y = y_plus;
      parea.w = area_width;
      parea.h = 30;   
      parea.idx = idx;
      pareaList.add(parea);
    }
  } 
}

void bgDraw() {   
  fill(255, 255, 255); 
  rect(0, 0, gWidth, gHeight); 
  
  background(255);
  stroke(74, 165, 255);
  strokeWeight(4);

  for(int j=0; j<3; j++) {
    for(int i=0; i<6; i++) {
      line(pulse1[0]+(area_space*j), pulse1[1]+(area_height*i), pulse1[0]+area_width+(area_space*j), pulse1[1]+(area_height*i));
    } 
  }
      
  for(int j=0; j<3; j++) {
    for(int i=0; i<6; i++) {
      line(pulse2[0]+(area_space*j), pulse2[1]+(area_height*i), pulse2[0]+area_width+(area_space*j), pulse2[1]+(area_height*i));
    } 
  } 
  drawPulse();
}

void mouseMoved() {   
  noStroke();
  bgDraw();
  
  if (!draggingText) {
      for(int i=0; i<pareaList.size(); i++) {                            
        PulseArea parea = (PulseArea)pareaList.get(i);
        if(areaSelectIdx == parea.idx) {                       
          fill(255, 255, 0);
          rect(parea.x, parea.y, parea.w, parea.h);
        } else {  
          if(mouseX >= parea.x && mouseX <= (parea.x+parea.w) && mouseY >= parea.y && mouseY <= (parea.y+parea.h)) { 
            if(batchPulseType > 0) {
               fill(200, 255, 200, 150);
            } else if (batchPulseType == -1) {
               fill(255, 200, 200, 150);
            } else {
               fill(255, 255, 149, 100);
            }
            rect(parea.x, parea.y, parea.w, parea.h);
          }                
        } 
      }
  }
  
  drawPulse();
  drawTongue();
}

boolean isOverText() {
  if (currentTongueText.length() == 0) return false;
  
  textFont(fontTongueText);
  float tw = textWidth(currentTongueText);
  String[] lines = split(currentTongueText, "\n");
  float th = lines.length * 16; 
  
  return (mouseX >= textX && mouseX <= textX + tw + 20 && mouseY >= textY && mouseY <= textY + th + 10);
}

void mousePressed() { 
  if (isOverText()) {
    draggingText = true;
    dragOffsetX = mouseX - textX;
    dragOffsetY = mouseY - textY;
    return; 
  }

  noStroke(); 
  for(int i=0; i<pareaList.size(); i++) {                            
    PulseArea parea = (PulseArea)pareaList.get(i);
    if(mouseX >= parea.x && mouseX <= (parea.x+parea.w) && mouseY >= parea.y && mouseY <= (parea.y+parea.h)) {
      
      if (batchPulseType != 0) {
         if (batchPulseType == -1) {
             cancelPulseIdx(parea.idx);
         } else {
             areaSelectIdx = parea.idx;
             if (batchPulseType >= 90) addLongPulseType(batchPulseType);
             else if (batchPulseType >= 60 && batchPulseType < 70) addFastPulseType(batchPulseType);
             else if ((batchPulseType >= 30 && batchPulseType < 60)) addPulseTypeGroup(batchPulseType);
             else addPulseType(batchPulseType);
             areaSelectIdx = -1;
         }
      } else {
        if(areaSelectIdx != parea.idx) {                       
          areaSelectIdx = parea.idx;
        } else {                  
          areaSelectIdx = -1;
        } 
      }
    }
  }
  mouseMoved();
}

void mouseDragged() {
  if (draggingText) {
    textX = mouseX - dragOffsetX;
    textY = mouseY - dragOffsetY;
    mouseMoved(); 
  }
}

void mouseReleased() {
  draggingText = false;
}

void cancelPressed() {  
  noStroke();
  areaSelectIdx = -1;
  mouseMoved();
}

void drawArrow(int x, int y, int len) {
  line(x, y, x+len, y);
  line(x+len, y, x+len-5, y-4);
  line(x+len, y, x+len-5, y+4);
}

void drawSeMaiPattern(int x, int y) {
  line(x-1, y, x+1, y+2);
  line(x+4, y, x+6, y+2); 
}

void drawWeakPulseLine(int x, int y, int count) {
  for(int k=0; k<count; k++) { 
     line(x+(k*10), y, x+(k*10)+4, y); 
  }
}

void drawTongue() {
  int tx = 740; 
  int ty = 245; 
  int w = 40; 
  
  if (currentTongueType == 1) w = 30;
  else if (currentTongueType == 2) w = 40;
  else if (currentTongueType == 3) w = 50;
  
  if (currentTongueType > 0) {
    noFill();
    stroke(0);
    strokeWeight(3);
    
    beginShape();
    vertex(tx - w*2/3, ty);
    bezierVertex(tx - w*2/3, ty + 70, tx + w*2/3, ty + 70, tx + w*2/3, ty);
    endShape();
  }
  
  if (currentTongueText.length() > 0) {
    fill(0);
    textFont(fontTongueText); 
    textAlign(LEFT, TOP); 
    text(currentTongueText, textX, textY); 
    noFill();
    
    if (draggingText) {
       noFill();
       stroke(200);
       strokeWeight(1);
       float tw = textWidth(currentTongueText);
       String[] lines = split(currentTongueText, "\n");
       float th = lines.length * 16;
       rect(textX, textY, tw, th);
    }
  }
}

void drawPulse() {
  for(int i=0; i<bloodList.size(); i++) {                     
    ArrayList blist = (ArrayList)bloodList.get(i);
    int group_idx = 1;      
           
    for(int j = 0; j < blist.size(); j++) {
      BloodType bt = (BloodType)blist.get(j);
      stroke(0);
      strokeWeight(2);
      noFill();

      if(bt.type == 11) {     
        int y = bt.y+15;
        int x = bt.x+22;
        if (bt.width_type > 0) {
           int y2 = 0;
           if(bt.width_type < 16) { 
               y = bt.y+9; 
               y2 = y + (bt.width_type - 12)*3; 
           } else { 
               y = bt.y+5;
               y2 = y + (bt.width_type - 12)*3 + 5; 
           }
           drawWeakPulseLine(x, y, 13);
           drawWeakPulseLine(x, y2, 13);
        } else {
           drawWeakPulseLine(x, y, 13);
        }
      } 
      else if(bt.type == 12) {     
        int y = bt.y+15;
        int x = bt.x+22; int x2 = x+120; 
        line(x, y, x2, y);
      } 
      else if(bt.type == 19) {
        int y = bt.y+15;
        int x = bt.x+22; 
        if (bt.width_type > 0) {
           int y2 = 0;
           if(bt.width_type < 16) { 
               y = bt.y+9; 
               y2 = y + (bt.width_type - 12)*3; 
           } else { 
               y = bt.y+5;
               y2 = y + (bt.width_type - 12)*3 + 5; 
           }
           
           drawWeakPulseLine(x, y, 6);
           line(x+60, y, x+120, y);
           
           drawWeakPulseLine(x, y2, 6);
           line(x+60, y2, x+120, y2);
        } else {
           drawWeakPulseLine(x, y, 6);
           line(x+60, y, x+120, y);
        }
      }
      else if(bt.type >= 13 && bt.type <= 17) {     
        int y = bt.y+5;
        int y2 = 0; int x = bt.x+22; int x2 = x+120; 
        if(bt.type < 16) { y = bt.y+9;
        y2 = y+(bt.type-12)*3; } else { y = bt.y+5; y2 = y+(bt.type-12)*3+5; }
        line(x, y, x2, y);
        line(x, y2, x2, y2);
      } 
      else if(bt.type == 18) {     
        int y = bt.y+5;
        int y2 = y+8; int x = bt.x+22; int x2 = x+120; 
        strokeWeight(4); line(x, y, x2, y);
        line(x, y2, x2, y2);  
      } 
      else if(bt.type >= 21 && bt.type <= 25) {    
        int x1 = 0; int x2 = 0;
        int y1 = 0; int y2 = 0;
        
        int targetWidthType = 0;
        
        for(int a=0; a<blist.size(); a++) {
          BloodType tmp_bt = (BloodType)blist.get(a);
          
          if((tmp_bt.type == 11 || tmp_bt.type == 19) && tmp_bt.width_type > 0) {
              targetWidthType = tmp_bt.width_type;
              break;
          }
          else if(tmp_bt.type >= 13 && tmp_bt.type <= 18) {
              targetWidthType = tmp_bt.type;
              break;
          }
        }
        
        if (targetWidthType >= 13 && targetWidthType <= 15) {
            y1 = bt.y + 5;
        } 
        else if (targetWidthType >= 16 && targetWidthType <= 18) {
            y1 = bt.y + 1;
        } 
        else {
            y1 = bt.y + 11;
        }
        
        y2 = y1 + 8; 
        
        for(int a=21; a<=bt.type; a++) { 
           x1 = bt.x+25+(a-21)*4;
           x2 = x1+3; 
           line(x1, y1, x2, y2); 
        }
      } 
      
      else if(bt.type == 31) {     
        int y = bt.y+6;
        int x = bt.x+110 - (bt.group_size-group_idx)*23;
        int y2 = y+17; int x2 = x+18; 
        line(x, y, x2, y);
        line(x, y2, x2, y2); arc(x+9, y+8, 8, 16, 0, TWO_PI); group_idx++;
      } else if(bt.type == 32) {     
        int y = bt.y+22;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        arc(x, y, 22, 22, PI, TWO_PI); arc(x, y, 10, 10, PI, TWO_PI); group_idx++;
      } else if(bt.type == 33) {     
        int y = bt.y+22;
        int x = bt.x+110 - (bt.group_size-group_idx)*23; int x2 = x+5;
        line(x, y, x, y-12); line(x+22, y, x+22, y-12);
        line(x, y-12, x+21, y-12); 
        line(x2, y, x2, y-6); line(x2+12, y, x2+12, y-6); line(x2, y-6, x2+11, y-6); group_idx++;
      } else if(bt.type == 34) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*26;
        arc(x, y, 10, 10, 0, PI+(PI*1/5)); arc(x+10, y, 10, 10, PI, TWO_PI+(PI*1/5)); group_idx++;
      } else if(bt.type == 35) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        arc(x, y, 15, 10, 0, TWO_PI); line(x-2, y-3, x-5, y+3); line(x+1, y-3, x-1, y+3);
        line(x+2, y+3, x+5, y-3); group_idx++;        
      } else if(bt.type == 36) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        line(x-7, y+5, x-2, y-5); line(x-2, y-5, x+2, y+5); line(x+2, y+5, x+7, y-5); group_idx++;
      } else if(bt.type == 37) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        arc(x, y, 13, 13, 0, TWO_PI); arc(x, y, 8, 8, 0, TWO_PI); group_idx++;
      } else if(bt.type == 38) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        arc(x, y, 13, 13, 0, TWO_PI); line(x-4, y-4, x+4, y+4); line(x-4, y+4, x+4, y-4);
        group_idx++;
      } else if(bt.type == 39) {     
        int y = bt.y+6;
        int x = bt.x+110 - (bt.group_size-group_idx)*23;
        int y2 = y+17; int x2 = x+18;
        line(x-3, y, x2, y);
        line(x-3, y2, x2, y2); arc(x+9, y+8, 8, 16, 0, TWO_PI);
        line(x-2, y-2, x, y+2); line(x+2, y-2, x+4, y+2);
        line(x-2, y2-2, x, y2+2); line(x+2, y2-2, x+4, y2+2); group_idx++;
      } else if(bt.type == 40) {     
        int y = bt.y+17;
        int x = bt.x+120 - (bt.group_size-group_idx)*23; int x2 = x+18;
        line(x, y, x2, y); strokeWeight(3); point(x+9, y-4); point(x+9, y+4); group_idx++;
      } else if(bt.type == 41) {     
        int y = bt.y+15;
        int x = bt.x+120 - (bt.group_size-group_idx)*23;
        arc(x, y, 12, 12, 0, TWO_PI); line(x-3, y-1, x-1, y+1); line(x+1, y-1, x+3, y+1);
        group_idx++;
      } else if(bt.type == 51) {     
        int y = bt.y+27;
        int x = bt.x+150; 
        line(x-1, y, x+1, y-10); arc(x-2, y-9, 4, 4, PI, TWO_PI); arc(x+6, y-5, 10, 10, PI, TWO_PI);
        line(x+12, y, x+11, y-5);      
      } else if(bt.type == 52) {     
        int y = bt.y+5; int x = bt.x+150; 
        drawSeMaiPattern(x, y);
      } else if(bt.type == 53) {
        int y = bt.y+5; int x = bt.x+150; 
        drawSeMaiPattern(x, y);
        drawSeMaiPattern(x+10, y+5);
      } else if(bt.type == 61 || bt.type == 64 || bt.type == 65) {
        int idx = (int)(bt.idx/5);
        int x = 50 + area_space*(idx%3); 
        int y = ( (idx/3)>=1 ) ? 320-10 : 50-10;   
        int len = 15;  
        int w = -20;
        int spacing = 25;
        drawArrow(x+w, y, len);
        if (bt.type == 64 || bt.type == 65) drawArrow(x+w+spacing, y, len);
        if (bt.type == 65) drawArrow(x+w+spacing*2, y, len);
      } else if (bt.type == 62) {
        int idx = (int)(bt.idx/5);
        int x = 50 + area_space*(idx%3); 
        int y = ( (idx/3)>=1 ) ? 320-10 : 50-10;   
        int len = 10;
        int w = -20; int w2 = w+len+10; int w3 = w2+len+10;
        y = bt.y + 25;
        line(x+w, y, x+w+4, y); line(x+w+10, y, x+w+14, y);         
        line(x+w2, y, x+w2+4, y); line(x+w2+10, y, x+w2+14, y);        
        line(x+w3, y, x+w3+len, y);
        line(x+w3+len, y, x+w3+len-5, y-3); line(x+w3+len, y, x+w3+len-5, y+3);
      } else if (bt.type == 63) {
        int idx = (int)(bt.idx/5);
        int x = 50 + area_space*(idx%3); 
        int y = ( (idx/3)>=1 ) ? 320-10 : 50-10;   
        int len = 10;
        int w = -20; int w2 = w+len+10; int w3 = w2+len+10;
        line(x+w, y, x+w+len, y); line(x+w+len, y, x+w+len-5, y-3);
        line(x+w+len, y, x+w+len-5, y+3);  
        line(x+w2, y, x+w2+len, y); line(x+w2+len, y, x+w2+len-5, y-3); line(x+w2+len, y, x+w2+len-5, y+3); 
        line(x+w3, y, x+w3+len, y);
        line(x+w3+len, y, x+w3+len-5, y-3); line(x+w3+len, y, x+w3+len-5, y+3);
        arc(x+6, y, 61, 17, 0, TWO_PI);
      } else if(bt.type >= 71 && bt.type <= 76) {
        int x = bt.x;
        int y = bt.y+27;   
        int startW = 180;
        int count = 1;
        if (bt.type == 72 || bt.type == 75) count = 2;
        else if (bt.type == 73 || bt.type == 76) count = 3;
        
        boolean isDown = (bt.type >= 74);
        
        for(int k=0; k<count; k++) {
           int w = startW + (k*7);
           line(x+w, y, x+w, y-12);
           
           if (isDown) {
               line(x+w, y, x+w-3, y-5);
               line(x+w, y, x+w+3, y-5);
           } else {
               line(x+w, y-12, x+w-3, y-7);
               line(x+w, y-12, x+w+3, y-7);
           }
        }
      } else if(bt.type == 81) {     
        int x = bt.x;
        int y = bt.y+37; int w = 20;
        line(x+w, y, x+w-10, y-6); line(x+w, y, x+w+10, y-6);
      } else if(bt.type == 82) {     
        int x = bt.x;
        int y = bt.y+35; int w = 20;
        line(x+w-2, y-6, x+w-2, y+3); line(x+w+2, y-6, x+w+2, y+3);
      } else if(bt.type == 83) {     
        int x = bt.x;
        int y = bt.y+37; int w = 20;
        line(x+w, y, x+w-10, y); line(x+w, y, x+w+10, y);
      } else if(bt.type == 91) {     
        int idx = (int)(bt.idx/15);
        int x = 10; int x2 = 770; int y = 0;   
        if(idx == 0) y = 140;
        else if(idx == 1) y = 410;
        line(x, y, x+10, y-10); line(x, y, x+10, y+10);        
        line(x2, y, x2-10, y-10);
        line(x2, y, x2-10, y+10);
      } else if(bt.type == 95) {
        int x = bt.x + 10;
        int y = bt.y + 20;
        fill(0);
        textFont(fontStar);
        text("☆", x, y);
        noFill();
      } else if(bt.type == 96) {
        int x = bt.x + 140;
        int y = bt.y + 20;
        fill(0);
        textFont(fontArrow);
        text("↷", x, y);
        noFill();
      } else if(bt.type == 99) {
        int cx = bt.x + 87;
        int cy = bt.y + 17;
        strokeWeight(3);
        noFill();
        ellipse(cx, cy-1.5, 40, 40);
        fill(0);
        textFont(fontWu);
        textAlign(CENTER, CENTER);
        text("無", cx, cy-2);
        textAlign(LEFT, BASELINE);
        noFill();
      }
    }
  }
}

void addPulseType(int ptype) {
  if(areaSelectIdx == -1) return;
  ArrayList blist = (ArrayList)bloodList.get(areaSelectIdx);
  
  if (ptype >= 13 && ptype <= 17) {
      boolean foundBase = false;
      for(int i = blist.size()-1; i >= 0; i--) {
         BloodType bt = (BloodType)blist.get(i);
         if (bt.type == 11 || bt.type == 19) {
             if (bt.width_type == ptype) {
                 blist.remove(i); 
             } else {
                 bt.width_type = ptype;
             }
             foundBase = true;
             break; 
         }
      }
      if (foundBase) { mouseMoved(); return; }
  }
  
  if(blist.size() > 0) { 
    for(int i = blist.size()-1; i >= 0; i--) {   
      BloodType bt = (BloodType)blist.get(i);
      if(ptype == bt.type) { blist.remove(i); mouseMoved(); return;
      } 
      int p1 = (int)(bt.type/10);
      int p2 = (int)(ptype/10);
      if(p1 == p2 && ptype < 90) { blist.remove(i); }
      if ((ptype == 52 && bt.type == 53) || (ptype == 53 && bt.type == 52)) { blist.remove(i); }
    }
  } 
  
  for(int i=0; i<pareaList.size(); i++) {                 
    PulseArea parea = (PulseArea)pareaList.get(i);
    if(parea.idx == areaSelectIdx) {               
        BloodType bt = new BloodType();
        bt.x = parea.x; bt.y = parea.y; bt.h = parea.h; bt.w = parea.w; bt.idx = parea.idx;
        bt.type = ptype;
        bt.group_size = 0;
        bt.width_type = 0; 
        blist.add(bt);
    }
  }
  mouseMoved(); 
}

void addPulseWithWidth(int ptype, int wtype) {
  if(areaSelectIdx == -1) return;
  ArrayList blist = (ArrayList)bloodList.get(areaSelectIdx);
  
  if(blist.size() > 0) { 
    for(int i = blist.size()-1; i >= 0; i--) {   
      BloodType bt = (BloodType)blist.get(i);
      if (bt.type == ptype) { blist.remove(i); }
      else if ((int)(bt.type/10) == 1) { blist.remove(i); }
    }
  }
  
  for(int i=0; i<pareaList.size(); i++) {                 
    PulseArea parea = (PulseArea)pareaList.get(i);           
    if(parea.idx == areaSelectIdx) {               
        BloodType bt = new BloodType();  
        bt.x = parea.x; bt.y = parea.y; bt.h = parea.h; bt.w = parea.w; bt.idx = parea.idx;
        bt.type = ptype; 
        bt.width_type = wtype; 
        bt.group_size = 0;
        blist.add(bt);
    }
  }
  mouseMoved(); 
}

void addLongPulseType(int ptype) {
  if(areaSelectIdx == -1) return;
  int areaID = (int)(areaSelectIdx/15);
  for(int i=(areaID*15); i<(areaID+1)*15; i++) {                     
    ArrayList blist = (ArrayList)bloodList.get(i);
    for(int j = blist.size()-1; j >= 0; j--) {   
      BloodType bt = (BloodType)blist.get(j);
      if(bt.type == ptype && (int)(bt.idx/15) == areaID) { blist.remove(j); mouseMoved(); return;
      } 
    }
  }
  ArrayList blist = (ArrayList)bloodList.get(areaSelectIdx);
  for(int i=0; i<pareaList.size(); i++) {                 
    PulseArea parea = (PulseArea)pareaList.get(i);
    if(parea.idx == areaSelectIdx) {                
        BloodType bt = new BloodType();
        bt.x = parea.x; bt.y = parea.y; bt.h = parea.h; bt.w = parea.w; bt.idx = parea.idx;
        bt.type = ptype;
        bt.group_size = 0;
        blist.add(bt);
    }
  } 
  mouseMoved();
}

void addFastPulseType(int ptype) {
  if(areaSelectIdx == -1) return;
  int areaID = (int)(areaSelectIdx/5);
  for(int i=(areaID*5); i<(areaID+1)*5; i++) {                     
    ArrayList blist = (ArrayList)bloodList.get(i);
    for(int j = blist.size()-1; j >= 0; j--) {   
      BloodType bt = (BloodType)blist.get(j);
      int areaIDtmp = (int)(bt.idx/5); int typeIDtmp = (int)(bt.type/10);       
      if(bt.type == ptype && areaIDtmp == areaID) { blist.remove(j); mouseMoved(); return;
      } 
      else if(typeIDtmp == 6) { blist.remove(j);
      } 
    }
  }
  ArrayList blist = (ArrayList)bloodList.get(areaSelectIdx);
  for(int i=0; i<pareaList.size(); i++) {                 
    PulseArea parea = (PulseArea)pareaList.get(i);
    if(parea.idx == areaSelectIdx) {                
      BloodType bt = new BloodType();
      bt.x = parea.x; bt.y = parea.y; bt.h = parea.h; bt.w = parea.w; bt.idx = parea.idx;
      bt.type = ptype;
      bt.group_size = 0;
      blist.add(bt);
    }
  } 
  mouseMoved();
}

void addPulseTypeGroup(int ptype) {
  if(areaSelectIdx == -1) return;
  int findId = 0; int group_size = 0; int group_slow_fast_size = 0;      
  ArrayList blist = (ArrayList)bloodList.get(areaSelectIdx);
  if(blist.size() > 0) {                               
    for(int i = blist.size()-1; i >= 0; i--) {   
      BloodType bt = (BloodType)blist.get(i);
      if(ptype == bt.type) { blist.remove(i); findId = 1; } 
      else if(bt.type > 30 && bt.type < 50) { group_size++;
      } 
      else if(bt.type > 60 && bt.type < 70) { group_slow_fast_size++;
      } 
    }
  }
  if(findId == 0) {
    for(int i=0; i<pareaList.size(); i++) {                 
      PulseArea parea = (PulseArea)pareaList.get(i);
      if(parea.idx == areaSelectIdx) {         
        if(ptype > 30 && ptype < 50) group_size++;
        else if(ptype > 60 && ptype < 70) group_slow_fast_size++;
        BloodType bt = new BloodType();
        bt.x = parea.x; bt.y = parea.y;
        bt.h = parea.h; bt.w = parea.w; bt.idx = parea.idx; bt.type = ptype;
        if(ptype > 60 && ptype < 70) bt.group_size = group_slow_fast_size;
        else if(ptype > 30 && ptype < 50) bt.group_size = group_size;
        blist.add(bt);
      }
    }
  }       
  for(int i = blist.size()-1; i >= 0; i--) {   
    BloodType bt = (BloodType)blist.get(i);
    if(bt.type > 30 && bt.type < 50) { bt.group_size = group_size; blist.remove(i); blist.add(bt);
    } 
    else if(bt.type > 60 && bt.type < 70) { bt.group_size = group_slow_fast_size; blist.remove(i); blist.add(bt);
    } 
  }
  mouseMoved(); 
}

void cancelPulseIdx(int idx) {
    ArrayList blist = (ArrayList)bloodList.get(idx);
    if(blist.size() > 0) { 
        for(int i = blist.size()-1; i >= 0; i--) { blist.remove(i); }
    }
    mouseMoved();
}

void cancelPulse() {    
  if(areaSelectIdx == -1) return;
  cancelPulseIdx(areaSelectIdx);
}

void clearAllPulses() {
    for(int i=0; i<bloodList.size(); i++) {
        ArrayList blist = (ArrayList)bloodList.get(i);
        for(int j = blist.size()-1; j >= 0; j--) { blist.remove(j); }
    }
    setTongueType(0); 
    setTongueNote(""); 
    mouseMoved();
}

String getPulseObj() {            
  String str = "";
  for(int i=0; i<bloodList.size(); i++) {                     
    ArrayList blist = (ArrayList)bloodList.get(i);
    for(int j = blist.size()-1; j >= 0; j--) {   
      BloodType bt = (BloodType)blist.get(j);
      str += bt.idx + ":" + bt.type + "@";
    }
  }
  return str;
}
