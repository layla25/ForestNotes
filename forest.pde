import processing.sound.*;
SoundFile sf;
ArrayList<grass>Grass=new ArrayList<grass>();
ArrayList<seed> seeds=new ArrayList<seed>();
ArrayList<tree> trees=new ArrayList<tree>();
ArrayList<leaflet> leaflets=new ArrayList<leaflet>();
ArrayList<PImage> leafbac=new ArrayList<PImage>();
ArrayList<PFont> f=new ArrayList<PFont>();
PImage leafphoto;
PImage summarybac;
PImage bin;
PImage leafbacc;
PImage leafbacs;
PImage appleclock;
PImage leafcor;
int treeInd=0;
float GRAVITY=0.05;
int timer=0;
long clock=0;
long clockend=0;
int sumarydy=0;
boolean shiftColorFlag=true;
boolean treeplanted=false;
boolean treegrowed=false;
boolean leafletopen=false;
boolean summaryopen=false;
boolean appleopen=false;
boolean swingonce=false;
boolean start=false;
boolean clockstart=false;
int activenum=0;
int curLineW=6;
int curColor=0;
int curFont=0;
int swingclock=0;
int textalpha=0;
int crossX=450;
int crossY=30;
int d=30;
float rotatedegree=PI/90;
color lc=color(0);
leaflet curleaflet;

//provide display function, used to draw the grass at the bottom
class grass
{
  int rootX,rootY,c,dX,dY,endPoint;
  grass(int a,int b,int C)
  {
    rootX=a;
    rootY=b;
    c=C;
  }
  void display()
  {
    noStroke();
    fill(0,c,0);
    float d=random(-2,5);
    boolean left=true;
    if(dX<-(d*2)) 
      left = false;
    if(left)
      dX += random(-d, -d/2);
    else
      dX += random(d/2, d);
    if(dX<-(d*1.1))
      dY = -6;
    else dY = 0;
    beginShape();
    curveVertex(rootX-5, rootY);
    curveVertex(rootX-5, rootY);
    curveVertex(rootX+endPoint, rootY-25+dY);
    curveVertex(rootX+2, rootY);
    curveVertex(rootX+4, rootY);
    endShape();
  }
}

//save the status, position and speed of seed. 
class seed
{
  float x,y,speed;
  int status,time,alpha;// 0 for drop, 1 for rest, 2 for dig, 3 for disappear
  seed(float a,float b)
  {
    x=a;
    y=b;
    speed=0;
    status=0;
    alpha=270;
  }
  void drop()
  {
    if(status==0)//fall
    {
      this.y+=this.speed;
      this.speed+=GRAVITY;
      if(this.y>700)
      {  
        this.y=700;
        this.status=1;
        this.time=5;
      }
    }
    else if(status==1)//rest
    {
      if(this.time--<=0)
        this.status=2;
      this.speed=0.5;
    }
    else if(status==2)//dig
    {
      if(this.speed>=0)
      {
        this.speed-=0.01;
        this.y+=this.speed;
      }
      else 
      {
        status=3;
        trees.add(new tree(x,y));
      }
    }
    else//disappear
    {
      if(this.alpha>0)
        this.alpha-=10;
    }
    noStroke();
    fill(119,119,60,this.alpha);
    ellipse(this.x, this.y, 8, 8);
  }
}
class tree
{
  float x,y;
  ArrayList<branch> branches=new ArrayList<branch>();
  tree(float a,float b)
  {
    x=a;
    y=b;
    branches.add(new branch(x,y,130,treeInd,PI/2,0,30));
    treeInd++;
  }
  void addBranch(branch s)
  {
    branches.add(s);
  }
  void grow()
  {
    for(int i=0;i<branches.size();i++)
      branches.get(i).grow();
  }
  void swing()
  {
    if(rotatedegree>=PI/1000)
      rotatedegree-=rotatedegree/160;
    else 
      rotatedegree=0;
    branches.get(0).swing(x,y,swingclock++);
  }
  void pause()
  {
    branches.get(0).pause(x,y);
    rotatedegree=PI/60;
    swingclock=0;
    swingonce=false;
  }
}
class branch
{
  ArrayList<leaf> leaves=new ArrayList<leaf>();
  ArrayList<branch> children=new ArrayList<branch>();
  float x1,y1,x2,y2,len,curLen,degree,weight,sr=0,dr=0,ddr=0;
  int depth,treeID;
  int colors[]=new int[2];
  boolean growed=false;
  branch(float a, float b,float c,int d,float e,int f,float g)
  {
    x1=a;
    y1=b;
    len=c;
    treeID=d;
    degree=e;
    curLen=0;
    depth=f;
    weight=g;
    for(int i=0;i<2;i++)
      colors[i]=int(random(60,80));
  }
  boolean within(float a,float b)
  {
    return a<=weight+x1&&a>=x1-weight&&b<=y1&&b>=y2;
  }
  void grow()
  {
    if(curLen<len)
      curLen+=1;
    x2=x1+curLen*cos(degree+sr);
    y2=y1-curLen*sin(degree+sr);
    if(!growed&&curLen>=len)
    {
      int branchnum=int(random(4,6));
      float bias=(2*PI/3)/(branchnum-1);
      for(int i=0;i<branchnum;i++)
      {
        if(depth+1<6)  
        {
          branch tmp=new branch(x2,y2,len/1.5,treeID,degree-PI/3+bias*i,depth+1,weight/1.6);
          trees.get(treeID).addBranch(tmp);
          children.add(tmp);
        }
        else 
        {
          leaves.add(new leaf(x2,y2,len/1.4,y2));
          break;
        }
      }
      growed=true;
    }
    colorMode(HSB,360,90,90);
    stroke(color(34,26,28));
    colorMode(RGB,255);
    strokeWeight(7);
    line(x1,y1,x2,y2);
    strokeWeight(1);
    for(int i=0;i<leaves.size();i++)
      leaves.get(i).grow();
  }
  void swing(float a,float b,float c)
  {
    sr=rotatedegree*sin(c/10);
    x1=a;
    y1=b;
    x2=x1+curLen*cos(degree+sr);
    y2=y1-curLen*sin(degree+sr);
    for(int i=0;i<children.size();i++)
    {
      children.get(i).swing(x2,y2,c+10);
    }
    for(int i=0;i<leaves.size();i++)
    {
      leaves.get(i).swing(x2,y2);
    }
  }
  void pause(float a,float b)
  {
    x1=a;
    y1=b;
    sr=0;
    x2=x1+curLen*cos(degree+sr);
    y2=y1-curLen*sin(degree+sr);
    for(int i=0;i<children.size();i++)
    {
      children.get(i).pause(x2,y2);
    }
    for(int i=0;i<leaves.size();i++)
    {
      leaves.get(i).pause(x2,y2);
    }
  }
}
class leaf
{
  float x,y,radius,rc,speed,period,py,dx,dy,vA,hA,dground;
  int colors[]=new int [3];
  int status,falltime,peacetime,timer,alpha;
  leaflet cleaflet;
  leaf(float a,float b, float d,float e)
  {
    rc=0;
    x=a;
    y=b;
    radius=d+5+random(0,5)-random(0,5);
    speed=random(0.1,0.4);
    for(int i=0;i<3;i++)
      colors[i]=int(random(75,100));
    status=0;
    falltime=int(random(30,99000));
    timer=0;
    period=random(5,9);
    dground=random(9,20);
    alpha=190;
    py=e;
    dx=0;
    dy=0;
    vA=0.5*(1+period*0.7);
    hA=4*(1+period*0.7);
    cleaflet=new leaflet(this);
    leaflets.add(cleaflet);
  }
  boolean within(float a,float b)
  {
    return (a-x-dx)*(a-x-dx)+(b-y-dy)*(b-y-dy)<=rc*rc;
  }
  void swing(float a,float b)
  {
    if(timer<falltime)
    {
      x=a;
      y=b;
    }
  }
  void pause(float a,float b)
  {
    if(timer<falltime)
    {
      x=a;
      y=b;
    }
  }
  void grow()
  { 
    if(timer<falltime)
    {
      rc+=radius/5;
      if(rc>=radius)
      {
        rc=radius;
        treegrowed=true;
      }
      timer++;
    }
    else if(y+dy<700+dground)
    {
      y+=speed;
      dx=sin((y-py)/period)*hA;
      dy=cos(2*(y-py)/period+PI)*vA+vA;
      timer++;
    }
    else 
    {
      if(alpha>=0)
        alpha--;
    }
    colorMode(HSB,360,100,100);
    fill(color(300,100-colors[0],colors[1],alpha));
    colorMode(RGB,255);
    noStroke();
    ellipse(x+dx, y+dy, rc, rc);
  }
}
class LINE
{
  int fx,fy,tx,ty,w;
  color C;
  LINE(int a,int b,int c,int d,color e,int f)
  {
    fx=a;
    fy=b;
    tx=c;
    ty=d;
    C=e;
    w=f;
  }
}
class leaflet
{
  leaf pleaf;
  ArrayList<LINE>lines=new ArrayList<LINE>();
  String s=new String();
  int tx=110,ty=170,bcolor=0;
  int posX,posY;
  float degree=random(-PI/6,PI/6);
  boolean active=false;
  leaflet(leaf i)
  {
    pleaf=i;
    s="";
  }
  void show()
  {
    if(leafletopen==true)
    {
      noStroke();
      image(leafbacc, 0, 0);
      image(leafcor,0,0);
      image(appleclock,5,150);
      image(bin,122,632);
      stroke(color(0));
      strokeWeight(2);
      line(35,76,35,155);
      if(appleopen)
      {
        noFill();
        arc(35,181,90,90,-PI/3,5*PI/9);
        arc(35,181,150,150,-PI/3,5*PI/9);
        for(int i=1;i<6;i+=2)
          line(35+45*cos(i*PI/9),181+45*sin(i*PI/9),35+75*cos(i*PI/9),181+75*sin(i*PI/9));
        for(int i=1;i<4;i+=2)
          line(35+45*cos(i*PI/9),181-45*sin(i*PI/9),35+75*cos(i*PI/9),181-75*sin(i*PI/9));
        pushMatrix();
        textSize(20);
        fill(0);
        translate(35,181);
        rotate(2*PI/9);
        text("1",0,-52);
        rotate(2*PI/9);
        text("5",0,-52);
        rotate(2*PI/9);
        text("10",0,-52);
        rotate(2*PI/9);
        text("15",0,-52);
        popMatrix();
      }
      stroke(color(0));
      strokeWeight(4);
      line(crossX,crossY,crossX+d,crossY+d);
      line(crossX+d,crossY,crossX,crossY+d);
      fill(0);
      textFont(f.get(curFont));
      textSize(40);
      text(s,tx,ty);
      fill(5,5,5,230);
      textSize(40);
      text("A",190,665);
      noStroke();
      fill(26,198,255,270);
      ellipse(450,650,40,40);
      fill(255,255,0,270);
      ellipse(390,650,40,40);
      fill(102, 255, 102,270);
      ellipse(330,650,40,40);
      fill(255, 51, 0,270);
      ellipse(270,650,40,40);
      if(s!=""||lines.size()>=1)
      {
        active=true;
        activenum++;
      }
      else 
      {
        active=false;
        activenum--;
      }
    }
  }
  void show(int x,int y)
  {
      pushMatrix();
      translate(x+85,y+115);
      rotate(degree);
      noFill();
      stroke(0);
      strokeWeight(5);
      beginShape();
      vertex(-85,-115);
      vertex(85,-115);
      vertex(85,115);
      vertex(-85,115);
      vertex(-85,-115);
      endShape();
      image(leafbac.get(2*bcolor+1), -85, -115);
      fill(0);
      textSize(8);
      textFont(f.get(curFont));
      text(s,tx/3-85,ty/3-115);
      for(int i=0;i<lines.size();i++)
      {
        LINE l=lines.get(i);
        strokeWeight(l.w/3);
        stroke(l.C);
        line(l.fx/3-85,l.fy/3-115,l.tx/3-85,l.ty/3-115);
      }
      popMatrix();
  }
  void delete()
  {
    for (int j = 0; j < lines.size(); j++)
      lines.remove(lines.get(j));
    active=false;
    activenum--;
    leafletopen=false;
  }
}
void mouseClicked() {
    if(!treeplanted)
    {
      treeplanted=true;
      start=true;
      seeds.add(new seed(mouseX, mouseY));
    }
    else if(treegrowed&&!leafletopen&&!summaryopen)
    {
      for(int i=0;i<trees.get(0).branches.size()&&!leafletopen;++i)
        for(int j=0;j<trees.get(0).branches.get(i).leaves.size()&&!leafletopen;++j)
        {
          leaf l=trees.get(0).branches.get(i).leaves.get(j);
          if(l.within(mouseX,mouseY))
          {
            curleaflet=l.cleaflet;
            leafletopen=true;
          }
        }
      branch bigbranch=trees.get(0).branches.get(0);
      if(bigbranch.within(mouseX,mouseY))
        summaryopen=true;
    }
    else if(leafletopen)
    {
      if(mouseX<=crossX+d&&mouseX>=crossX&&mouseY>=crossY&&mouseY<=crossY+d)
      {
        leafletopen=false;
        appleopen=false;
        return;
      }
      if(mouseX<=5+60&&mouseX>=5&&mouseY>=150&&mouseY<=150+60)
      {
        appleopen=!appleopen;
        return;
      }
      if(mouseX<=30&&mouseY<=30)
      {
        curColor++;
        if(curColor>=4)
          curColor=0;
        leafbacc=leafbac.get(curColor*2);
        curleaflet.bcolor=curColor;
        return;
      }
      if(mouseX<=450+20&&mouseX>=450-20&&mouseY>=650-20&&mouseY<=650+20)
        lc=color(26,198,255,270);
      if(mouseX<=390+20&&mouseX>=390-20&&mouseY>=650-20&&mouseY<=650+20)
        lc=color(255,255,0,270);
      if(mouseX<=330+20&&mouseX>=330-20&&mouseY>=650-20&&mouseY<=650+20)
        lc=color(102, 255, 102,270);
      if(mouseX<=270+20&&mouseX>=270-20&&mouseY>=650-20&&mouseY<=650+20)
        lc=color(255, 51, 0,270);
      if(mouseX<=210+20&&mouseX>=210-20&&mouseY>=650-20&&mouseY<=650+20)
      {
        curFont++;
        if(curFont>=f.size())
          curFont=0;
        println(curFont);
        return;
      }
      float r2=(mouseX-35)*(mouseX-35)+(mouseY-181)*(mouseY-181);
      if(r2<=75*75&&r2>=45*45)
      {
        float dc=0;
        float a=mouseY-181,b=mouseX-35;
        if(b!=0)
          dc=atan(a/b);
        println(dc);
        if(dc<=3*PI/9&&dc>=PI/9)
          clockend=10*30;
        else if(dc<=1*PI/9&&dc>=-1*PI/9)
          clockend=5*30;
        else if(dc<=-1*PI/9&&dc>=-3*PI/9)
          clockend=1*30;
        else if(dc<=-3*PI/9&&dc>=-5*PI/9)
          clockend=15*30;
        println(clockend);
        clockstart=true;
        clock=0;
        appleopen=false;
      }
      if(mouseX<=150+20&&mouseX>=150-20&&mouseY>=650-20&&mouseY<=650+20)
        curleaflet.delete();
    }
    else if(summaryopen)
    {
      if(mouseX<=crossX+d&&mouseX>=crossX&&mouseY>=crossY&&mouseY<=crossY+d)
      {
        summaryopen=false;
        return;
      }
      for(int i=0;i<leaflets.size();i++)
      {
        if(leaflets.get(i).active)
        {
          int x=leaflets.get(i).posX,y=leaflets.get(i).posY;
          if(mouseX<=x+170&&mouseX>=x&&mouseY>=y+sumarydy&&mouseY<=y+sumarydy+230)
          {
            leafletopen=true;
            curleaflet=leaflets.get(i);
            break;
          }
        }
      }
    }
}
void mouseDragged() {
  if(leafletopen&&mousePressed
  &&mouseX<=510&&mouseX>=0&&mouseY<=700&&mouseY>=0&&pmouseX<=510
  &&pmouseX>=0&&pmouseY<=700&&pmouseY>=0)
  {
    if(mouseButton == LEFT)
      curleaflet.lines.add(new LINE(mouseX,mouseY,pmouseX,pmouseY,lc,curLineW)); 
    if(mouseButton == RIGHT)
      curleaflet.lines.add(new LINE(mouseX,mouseY,pmouseX,pmouseY,color(255),20)); 
  }
}
void keyPressed() {
  if(leafletopen)
  {
    if(key == BACKSPACE&&curleaflet.s!=""&&curleaflet.s.length()>=0)
      curleaflet.s=curleaflet.s.substring(0,curleaflet.s.length()-1);
    else if(key==DELETE)
      curleaflet.s="";
    else
      curleaflet.s+=key;
    if((curleaflet.s.length()+1)%30==0)
      curleaflet.s+="\n";
  }
  else
  {
    if(key==BACKSPACE)
      swingonce=true;
    if(key==DELETE)
      trees.get(0).pause();
  }
}
void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  if(leafletopen)
  {
      curLineW+=e;
      if(curLineW<=0)
        curLineW=0;
  }
  else if(summaryopen)
  {
    sumarydy-=4*e;
    if(sumarydy>=66)
      sumarydy-=50*e;
    if(sumarydy>=88)
      sumarydy=88;
  }
}
void drawbackground()
{
  for (int i = 0; i < width; i++) 
    for (int j = 0; j < height; j++) {
      colorMode(HSB,360,100,100);
      float x=float(j)/height*20;
      float y=float(i)/width*50;
      color c = color(215, 34,79+x);
      set(i, j, c);
      colorMode(RGB,255);
    }
}
void drawOpenning()
{
  if(!start)
  {
    if(textalpha<210)textalpha+=5;
  }
  else
  {
    if(textalpha>=0)textalpha-=5;
  }
  textSize(40);
  fill(color(255,255,255,textalpha));
  text("Press to plant a tree",50,190);
}

void draw()
{
  drawbackground();
  drawOpenning();
  for(int i=0;i<Grass.size();i++)
      Grass.get(i).display();
  for(int i=0;i<seeds.size();i++)
      seeds.get(i).drop();
  for(int i=0;i<trees.size();i++)
      trees.get(i).grow();
  if(leafletopen)
  {
    curleaflet.show();
    for(int i=0;i<curleaflet.lines.size();i++)
    {
      LINE l=curleaflet.lines.get(i);
      strokeWeight(l.w);
      stroke(l.C);
      line(l.fx,l.fy,l.tx,l.ty);
    }
  }
  else if(summaryopen)
  {
    image(leafbac.get(8),0,0);
    noFill();stroke(0);strokeWeight(2);
    rect(30,-80+sumarydy,400,30,7);
    ellipse(410,-67+sumarydy,13,13);
    line(415,-62+sumarydy,420,-57+sumarydy);
    int n=0;
    for(int i=0;i<leaflets.size();i++)
    {
      if(leaflets.get(i).active)
      {
        leaflets.get(i).show(170*(n%3),230*(n/3)+sumarydy);
        leaflets.get(i).posX=170*(n%3);
        leaflets.get(i).posY=230*(n++/3);
      }
    }
    stroke(0);strokeWeight(4);
    line(crossX,crossY,crossX+d,crossY+d);
    line(crossX+d,crossY,crossX,crossY+d);
  }
  if(swingonce)
    trees.get(0).swing();
  if(rotatedegree==0)
  {
    trees.get(0).pause();
    swingonce=false;
    sf.stop();
  }
  timer++;
  if(clockstart)
  {
    clock++;
    if(clock==clockend)
    {
      clockstart=false;
      clock=0;
      swingonce=true;
      sf.play();
    }
  }
}
void setup() 
{
   size(510,700);
   frameRate(30);
   background(230);
   leafphoto=loadImage("assets/leaf1.png");
   bin=loadImage("assets/bin.png");
   bin.resize(35,35);
   PImage tmp=leafbacc=loadImage("assets/back1.jpg");
   leafbac.add(tmp);
   tmp=loadImage("assets/back1.jpg");
   tmp.resize(170,230);
   leafbacs=tmp;
   leafbac.add(tmp);
   tmp=loadImage("assets/back2.jpg");
   leafbac.add(tmp);
   tmp=loadImage("assets/back2.jpg");
   tmp.resize(170,230);
   leafbac.add(tmp);
   tmp=loadImage("assets/back3.jpg");
   leafbac.add(tmp);
   tmp=loadImage("assets/back3.jpg");
   tmp.resize(170,230);
   leafbac.add(tmp);
   tmp=loadImage("assets/back4.jpg");
   leafbac.add(tmp);
   tmp=loadImage("assets/back4.jpg");
   tmp.resize(170,230);
   leafbac.add(tmp);
   leafbac.add(loadImage("assets/back0.jpg"));
   summarybac=loadImage("assets/summarybac.jpg");
   appleclock=loadImage("assets/appleclock.png");
   appleclock.resize(60,90);
   leafcor=loadImage("assets/cornerleaf.png");
   leafcor.resize(280,110);
   PFont temp=loadFont("ComicSansMS-25.vlw");
   f.add(temp);
   temp=loadFont("BlackadderITC-Regular-25.vlw");
   f.add(temp);
   temp=loadFont("Calibri-Light-25.vlw");
   f.add(temp);
   temp=loadFont("BerlinSansFB-Reg-25.vlw");
   f.add(temp);
   temp=loadFont("Calibri-Light-25.vlw");
   f.add(temp);
   temp=loadFont("AnonymousPro-Bold-25.vlw");
   f.add(temp);
   sf=new SoundFile(this,"wind.mp3");
   for(int i = 0;i<400;i++)
    Grass.add(new grass(i*5,700,int(random(180,255))));
}