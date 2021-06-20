// Tool for creating interlaced images for lenticular prints

String imagesFolder = "test";   // files named 0.png, 1.png, 2.png, 3...
String fileExtension = ".png";  // .png, .jpg, .tga or non-animated .gif
int framesTotal = 5;            // number of frames/files
int LPI = 50;                   // from lenticular sheet specifications
float printWidth = 4.3;         // desired width of the printed image in inches
int blurStrength = 0;           // most images look better blured

// end of user settings
  
int PPI = LPI * framesTotal;
int fW = int(printWidth * LPI);
int cW = fW * framesTotal; 
int fH, cH;
float ratio;
boolean toggle = true;

PImage[] frame = new PImage[framesTotal];
PImage composite;

PrintWriter output;

void setup() {
  size(500, 500);
  
  int sW = 0;
  for (int i = 0; i < framesTotal; i++) {
    frame[i] = loadImage(imagesFolder + "/" + i + fileExtension);

    if (i == 0) {
      ratio = float(frame[0].width) / float(frame[0].height);
      sW = frame[0].width;
      fH = frame[0].height;
      cH = int(cW / ratio);
    } 
    else {
      if ((sW != frame[i].width) || (fH != frame[i].height)) {
        println("All images should be the same size. Fix and restart!");
        exit(); 
        return;
      }
    }

    frame[i].filter(BLUR, blurStrength);
    frame[i].resize(fW, frame[i].height);  // discard unused horizontal resolution
    
    println(int((i+1) / float(framesTotal) * 100) + "% complete");
  }

  composite = createImage(cW, cH, RGB);

  // images interlacing, fx frame column, cx composite column
  // reversed order of frames since lens mirrors the image
  int cx = 0; 
  for (int fx = 0; fx < fW; fx++) { 
    for (int f = framesTotal-1; f >= 0; f--) {   
      composite.copy(frame[f], fx, 0, 1, fH, cx, 0, 1, cH);
      cx++;
    }
  }

  composite.save(imagesFolder + "_" + LPI + "lpi" + "_" + PPI + "ppi" + ".tif");
  printSpecs();
  
} // end of setup

void draw() {
  background(0);
  imageMode(CENTER);

  if (toggle) {
    image(frame[int(map(mouseX, 0, width, 0, framesTotal))], width/2, height/2, width, width/ratio); // ne radi kod vertikalnog omjera
  } else {
    image(composite, width/2, height/2, width, width/ratio);
  }
  
} // end of draw

void mousePressed() {
  toggle = !toggle;
}

void printSpecs() {
  StringList specs = new StringList();
  println();
  specs.append("image size (px) = " + cW + " × " + cH + " px");  
  specs.append("print size (in) = " + printWidth + " × " + (printWidth / ratio) + " in");
  specs.append("print size (cm) = " + printWidth * 2.54 + " × " + (printWidth / ratio) * 2.54 + " cm");
  specs.append("print resolution (PPI) = " + PPI);
  specs.append("lens LPI = " + LPI);
  specs.append("number of frames = " + framesTotal);
  
  saveStrings(imagesFolder + "_" + LPI + "lpi" + "_" + PPI + "ppi" + ".txt", specs.array());
  for (int i = 0 ; i < specs.size(); i++) println(specs.get(i));
}
