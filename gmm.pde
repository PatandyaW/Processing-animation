import ddf.minim.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

boolean upPressed, downPressed, leftPressed, rightPressed;

PImage[] tileImages;
PImage[] objectImage;
int tileSize = 50;
int numColumns, numRows;
int[][] tileMap;

PImage currentCharacterImage;

float characterX, characterY;
float characterSpeed = 8;

int transitionFrameCount = 10;

float cameraOffsetX, cameraOffsetY;

boolean isCollidingObject1 = false; // Collision state for object image 1
boolean isCollidingObject2 = false; // Collision state for object image 2
boolean isCollidingObject3 = false;
boolean isCollidingObject4 = false;

Minim minim;
AudioPlayer musicPlayer1, musicPlayer2, musicPlayer3, musicPlayer4;
boolean isPlayingMusic1 = false; // Flag to track if music 1 is playing
boolean isPlayingMusic2 = false; // Flag to track if music 2 is playing
boolean isPlayingMusic3 = false; // Flag to track if music 3 is playing
boolean isPlayingMusic4 = false;

void setup() {
  size(800, 650);
  characterX = 23 * tileSize;
  characterY = 21 * tileSize;

  // Load the image files
  tileImages = new PImage[6];
  tileImages[0] = loadImage("grass.png");
  tileImages[1] = loadImage("wall.png");
  tileImages[2] = loadImage("water.png");
  tileImages[3] = loadImage("earth.png");
  tileImages[4] = loadImage("tree.png");
  tileImages[5] = loadImage("sand.png");

  // Load the object image
  objectImage = new PImage[4];
  objectImage[0] = loadImage("recorder.png");
  objectImage[1] = loadImage("lute.png");
  objectImage[2] = loadImage("gamblang.png");
  objectImage[3] = loadImage("angklung.png");
  

  // Set the initial character image
  currentCharacterImage = loadImage("boy_right_1.png");

  // Load the tile map data from the text file
  loadTileMap("world01.txt");

  // Initialize Minim and load the music files
  minim = new Minim(this);
  musicPlayer1 = minim.loadFile("sabilulungan.mp3");
  musicPlayer2 = minim.loadFile("test.mp3");
  musicPlayer3 = minim.loadFile("angklung.mp3");
  musicPlayer4 = minim.loadFile("gambang.mp3");
}

void draw() {
  background(255);

  // Calculate the camera offset based on the character's position
  cameraOffsetX = width / 2 - characterX - tileSize / 2;
  cameraOffsetY = height / 2 - characterY - tileSize / 2;

  // Translate the drawing position based on the camera offset
  translate(cameraOffsetX, cameraOffsetY);

  // Determine the range of tiles to draw based on the camera offset
  int startColumn = max(0, floor((-cameraOffsetX) / tileSize));
  int endColumn = min(numColumns - 1, ceil((width - cameraOffsetX) / tileSize));
  int startRow = max(0, floor((-cameraOffsetY) / tileSize));
  int endRow = min(numRows - 1, ceil((height - cameraOffsetY) / tileSize));

  // Draw the tiles within the range
  for (int i = startColumn; i <= endColumn; i++) {
    for (int j = startRow; j <= endRow; j++) {
      int tileValue = tileMap[j][i];
      if (tileValue >= 0 && tileValue < tileImages.length) {
        PImage tileImage = tileImages[tileValue];
        image(tileImage, i * tileSize, j * tileSize, tileSize, tileSize);
      }

      // Check if it's the tile at (x = 23, y = 7) and draw the object image
      if (i == 23 && j == 7) {
        image(objectImage[0], i * tileSize, j * tileSize, tileSize, tileSize);
      }
      if (i == 23 && j == 40) {
        image(objectImage[1], i * tileSize, j * tileSize, tileSize, tileSize);
      }
      if (i == 37 && j == 7) {
        image(objectImage[2], i * tileSize, j * tileSize, tileSize, tileSize);
      }
      if (i == 10 && j == 8) {
        image(objectImage[3], i * tileSize, j * tileSize, tileSize, tileSize);
      }
    }
  }

  // Draw the character image at its current position
  image(currentCharacterImage, characterX, characterY, tileSize, tileSize);

  // Draw a rectangle around the character
  noStroke();
  noFill();
  rect(characterX + 8, characterY + 16, 32, 32);

  // Move the character based on the key states
  if (leftPressed) {
    if (!isColliding(characterX - characterSpeed, characterY, tileSize)) {
      characterX -= characterSpeed;
      int transitionFrame = frameCount % (transitionFrameCount * 2);
      currentCharacterImage = (transitionFrame < transitionFrameCount) ? loadImage("boy_left_1.png") : loadImage("boy_left_2.png");
    }
  }
  if (rightPressed) {
    if (!isColliding(characterX + characterSpeed, characterY, tileSize)) {
      characterX += characterSpeed;
      int transitionFrame = frameCount % (transitionFrameCount * 2);
      currentCharacterImage = (transitionFrame < transitionFrameCount) ? loadImage("boy_right_1.png") : loadImage("boy_right_2.png");
    }
  }
  if (upPressed) {
    if (!isColliding(characterX, characterY - characterSpeed, tileSize)) {
      characterY -= characterSpeed;
      int transitionFrame = frameCount % (transitionFrameCount * 2);
      currentCharacterImage = (transitionFrame < transitionFrameCount) ? loadImage("boy_up_1.png") : loadImage("boy_up_2.png");
    }
  }
  if (downPressed) {
    if (!isColliding(characterX, characterY + characterSpeed, tileSize)) {
      characterY += characterSpeed;
      int transitionFrame = frameCount % (transitionFrameCount * 2);
      currentCharacterImage = (transitionFrame < transitionFrameCount) ? loadImage("boy_down_1.png") : loadImage("boy_down_2.png");
    }
  }

  // Check for collision with object images
  isCollidingObject1 = isCollidingObject(characterX, characterY, tileSize, 23, 7);
  isCollidingObject2 = isCollidingObject(characterX, characterY, tileSize, 23, 40);
  isCollidingObject3 = isCollidingObject(characterX, characterY, tileSize, 37, 7);
  isCollidingObject4 = isCollidingObject(characterX, characterY, tileSize, 10, 8);

  // Draw collision rectangles if necessary
  if (isCollidingObject1) {
    drawCollisionRect(characterX - tileSize * 2, characterY - tileSize / 2, width - tileSize * 4, tileSize * 4);
    
    if (!isPlayingMusic1) {
      musicPlayer1.loop();
      isPlayingMusic1 = true;
    }
  } else {
    // Stop music 1 if not colliding with object2
    if (isPlayingMusic1) {
      musicPlayer1.pause();
      isPlayingMusic1 = false;
    }
  }
  
  if (isCollidingObject2) {
    drawCollisionRect(characterX - tileSize * 2, characterY - tileSize / 2, width - tileSize * 4, tileSize * 4);

    if (!isPlayingMusic2) {
      musicPlayer2.loop();
      isPlayingMusic2 = true;
    }
  } else {
    // Stop music 2 if not colliding with object3
    if (isPlayingMusic2) {
      musicPlayer2.pause();
      isPlayingMusic2 = false;
    }
  }
  if (isCollidingObject3) {
    drawCollisionRect(characterX - tileSize * 2, characterY - tileSize / 2, width - tileSize * 4, tileSize * 4);

    // Play music 2 when colliding with object3 if not already playing
    if (!isPlayingMusic4) {
      musicPlayer4.loop();
      isPlayingMusic4 = true;
    }
  } else {
    // Stop music 2 if not colliding with object3
    if (isPlayingMusic4) {
      musicPlayer4.pause();
      isPlayingMusic4 = false;
    }
  }
  if (isCollidingObject4) {
    drawCollisionRect(characterX - tileSize * 2, characterY - tileSize / 2, width - tileSize * 4, tileSize * 4);

    // Play music 3 when colliding with object4 if not already playing
    if (!isPlayingMusic3) {
      musicPlayer3.loop();
      isPlayingMusic3 = true;
    }
  } else {
    // Stop music 3 if not colliding with object4
    if (isPlayingMusic3) {
      musicPlayer3.pause();
      isPlayingMusic3 = false;
    }
  }
}

void keyPressed() {
  if (keyCode == LEFT) {
    leftPressed = true;
  }
  if (keyCode == RIGHT) {
    rightPressed = true;
  }
  if (keyCode == UP) {
    upPressed = true;
  }
  if (keyCode == DOWN) {
    downPressed = true;
  }
}

void keyReleased() {
  if (keyCode == LEFT) {
    leftPressed = false;
  }
  if (keyCode == RIGHT) {
    rightPressed = false;
  }
  if (keyCode == UP) {
    upPressed = false;
  }
  if (keyCode == DOWN) {
    downPressed = false;
  }
}

void loadTileMap(String filePath) {
  String[] lines = loadStrings(filePath);

  if (lines != null && lines.length > 0) {
    numColumns = lines[0].length();
    numRows = lines.length;
    tileMap = new int[numRows][numColumns];

    for (int j = 0; j < numRows; j++) {
      for (int i = 0; i < numColumns; i++) {
        char c = lines[j].charAt(i);
        tileMap[j][i] = Character.getNumericValue(c);
      }
    }
  }
}

boolean isColliding(float x, float y, int tileSize) {
  // Calculate the rectangle around the given position
  float rectX = x + 8;
  float rectY = y + 16;
  float rectWidth = 32;
  float rectHeight = 32;

  // Check for collision with specific tile values
  int leftTile = floor(rectX / tileSize);
  int rightTile = floor((rectX + rectWidth) / tileSize);
  int topTile = floor(rectY / tileSize);
  int bottomTile = floor((rectY + rectHeight) / tileSize);

  for (int i = leftTile; i <= rightTile; i++) {
    for (int j = topTile; j <= bottomTile; j++) {
      if (tileMap[j][i] == 1 || tileMap[j][i] == 2 || tileMap[j][i] == 4) {
        return true;
      }
    }
  }

  return false;
}

boolean isCollidingObject(float x, float y, int tileSize, int objectX, int objectY) {
  // Calculate the rectangle around the character
  float rectX = x + 8;
  float rectY = y + 16;
  float rectWidth = 32;
  float rectHeight = 32;

  // Calculate the rectangle around the object
  float objectRectX = objectX * tileSize;
  float objectRectY = objectY * tileSize;
  float objectRectWidth = tileSize;
  float objectRectHeight = tileSize;

  // Check for collision between the character and object
  return !(rectX + rectWidth <= objectRectX ||
           rectY + rectHeight <= objectRectY ||
           rectX >= objectRectX + objectRectWidth ||
           rectY >= objectRectY + objectRectHeight);
}

void drawCollisionRect(float x, float y, float width, float height) {
  // Check if colliding with objectImage[1]
  if (isCollidingObject2) {
    // Update the position of the collision rectangle
    x = characterX - tileSize * 5;
    y = characterY - tileSize * 5;

    // Draw the collision rectangle
    fill(0);
    stroke(255);
    rect(x, y, width, height);

    // Add text on the collision rectangle
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    String header = "Leko Boko";
    text(header, x + width / 2, y + 20);

    // Calculate the position of the text within the rectangle
    float textX = x + width / 2;
    float textY = y + height / 2;

    // Ensure the text stays within the rectangle
    float textWidth = textWidth("Leko boko adalah alat musik yang berasal dari Nusa Tenggara Timur (NTT), Leko boko atau orang biasa menyebut Bujol dibuat menggunakan labu hutan (wadah resonansi) dan kayu (untuk merentangkan senar)");
    float textHeight = textAscent() + textDescent();

    if (textWidth > width || textHeight > height) {
      // Calculate the number of lines needed to fit the text
      int numLines = ceil(textWidth / width);
      float lineHeight = textHeight * 1.5;

      // Split the text into multiple lines
      String[] textLines = splitText("Leko boko adalah alat musik yang berasal dari Nusa Tenggara Timur (NTT), Leko boko atau orang biasa menyebut Bujol dibuat menggunakan labu hutan (wadah resonansi) dan kayu (untuk merentangkan senar)", width);

      // Adjust the starting Y position to center the text vertically
      float startY = textY - (numLines / 2) * lineHeight;

      // Draw the text lines
      for (int i = 0; i < numLines; i++) {
        float lineY = startY + i * lineHeight;
        text(textLines[i], textX, lineY);
      }
    } else {
      // Draw the text as a single line
      text("Leko boko adalah alat musik yang berasal dari Nusa Tenggara Timur (NTT), Leko boko atau orang biasa menyebut Bujol dibuat menggunakan labu hutan (wadah resonansi) dan kayu (untuk merentangkan senar)", textX, textY);
    }
  }if (isCollidingObject1) {
    // Update the position of the collision rectangle
    x = characterX - tileSize * 5;
    y = characterY - tileSize * 5;

    // Draw the collision rectangle
    fill(0);
    stroke(255);
    rect(x, y, width, height);

    // Add text on the collision rectangle
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    String header = "Suling";
    text(header, x + width / 2, y + 20);

    // Calculate the position of the text within the rectangle
    float textX = x + width / 2;
    float textY = y + height / 2;

    // Ensure the text stays within the rectangle
    float textWidth = textWidth("Suling bambu berasal dari tanah Sunda, Jawa Barat. Alat musik tiup ini terbuat dari bambu dengan ciri-ciri berbentuk ramping yang panjang kurang lebih 15-30 cm dengan diameter berkisar 3-4 cm.");
    float textHeight = textAscent() + textDescent();

    if (textWidth > width || textHeight > height) {
      // Calculate the number of lines needed to fit the text
      int numLines = ceil(textWidth / width);
      float lineHeight = textHeight * 1.5;

      // Split the text into multiple lines
      String[] textLines = splitText("Suling bambu berasal dari tanah Sunda, Jawa Barat. Alat musik tiup ini terbuat dari bambu dengan ciri-ciri berbentuk ramping yang panjang kurang lebih 15-30 cm dengan diameter berkisar 3-4 cm.", width);

      // Adjust the starting Y position to center the text vertically
      float startY = textY - (numLines / 2) * lineHeight;

      // Draw the text lines
      for (int i = 0; i < numLines; i++) {
        float lineY = startY + i * lineHeight;
        text(textLines[i], textX, lineY);
      }
    } else {
      // Draw the text as a single line
      text("Suling bambu berasal dari tanah Sunda, Jawa Barat. Alat musik tiup ini terbuat dari bambu dengan ciri-ciri berbentuk ramping yang panjang kurang lebih 15-30 cm dengan diameter berkisar 3-4 cm.", textX, textY);
    }
  }if (isCollidingObject4) {
    // Update the position of the collision rectangle
    x = characterX - tileSize * 5;
    y = characterY - tileSize * 5;

    // Draw the collision rectangle
    fill(0);
    stroke(255);
    rect(x, y, width, height);

    // Add text on the collision rectangle
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    String header = "Angklung";
    text(header, x + width / 2, y + 20);

    // Calculate the position of the text within the rectangle
    float textX = x + width / 2;
    float textY = y + height / 2;

    // Ensure the text stays within the rectangle
    float textWidth = textWidth("Angklung adalah sebuah alat musik tradisional Indonesia yang terbuat dari bambu. Alat musik ini terdiri dari rangkaian tabung-tabung bambu dengan berbagai ukuran, yang masing-masing menghasilkan nada yang berbeda.");
    float textHeight = textAscent() + textDescent();

    if (textWidth > width || textHeight > height) {
      // Calculate the number of lines needed to fit the text
      int numLines = ceil(textWidth / width);
      float lineHeight = textHeight * 1.5;

      // Split the text into multiple lines
      String[] textLines = splitText("Angklung adalah sebuah alat musik tradisional Indonesia yang terbuat dari bambu. Alat musik ini terdiri dari rangkaian tabung-tabung bambu dengan berbagai ukuran, yang masing-masing menghasilkan nada yang berbeda.", width);

      // Adjust the starting Y position to center the text vertically
      float startY = textY - (numLines / 2) * lineHeight;

      // Draw the text lines
      for (int i = 0; i < numLines; i++) {
        float lineY = startY + i * lineHeight;
        text(textLines[i], textX, lineY);
      }
    } else {
      // Draw the text as a single line
      text("Angklung adalah sebuah alat musik tradisional Indonesia yang terbuat dari bambu. Alat musik ini terdiri dari rangkaian tabung-tabung bambu dengan berbagai ukuran, yang masing-masing menghasilkan nada yang berbeda.", textX, textY);
    }
  }if (isCollidingObject3) {
    // Update the position of the collision rectangle
    x = characterX - tileSize * 5;
    y = characterY - tileSize * 5;

    // Draw the collision rectangle
    fill(0);
    stroke(255);
    rect(x, y, width, height);

    // Add text on the collision rectangle
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    String header = "Gambang";
    text(header, x + width / 2, y + 20);

    // Calculate the position of the text within the rectangle
    float textX = x + width / 2;
    float textY = y + height / 2;

    // Ensure the text stays within the rectangle
    float textWidth = textWidth("Gambang adalah alat musik Jawa Tengah yang merupakan salah satu instrumen orkes gambang kromong dan gambang rancag. Gambang memiliki sumber suara sebanyak 20 buah bilah yang terbuat dari kayu atau bambu.");
    float textHeight = textAscent() + textDescent();

    if (textWidth > width || textHeight > height) {
      // Calculate the number of lines needed to fit the text
      int numLines = ceil(textWidth / width);
      float lineHeight = textHeight * 1.5;

      // Split the text into multiple lines
      String[] textLines = splitText("Gambang adalah alat musik Jawa Tengah yang merupakan salah satu instrumen orkes gambang kromong dan gambang rancag. Gambang memiliki sumber suara sebanyak 20 buah bilah yang terbuat dari kayu atau bambu.", width);

      // Adjust the starting Y position to center the text vertically
      float startY = textY - (numLines / 2) * lineHeight;

      // Draw the text lines
      for (int i = 0; i < numLines; i++) {
        float lineY = startY + i * lineHeight;
        text(textLines[i], textX, lineY);
      }
    } else {
      // Draw the text as a single line
      text("Gambang adalah alat musik Jawa Tengah yang merupakan salah satu instrumen orkes gambang kromong dan gambang rancag. Gambang memiliki sumber suara sebanyak 20 buah bilah yang terbuat dari kayu atau bambu.", textX, textY);
    }
  }
}

String[] splitText(String text, float maxWidth) {
  ArrayList<String> lines = new ArrayList<String>();
  String[] words = split(text, ' ');

  String currentLine = words[0];
  for (int i = 1; i < words.length; i++) {
    String word = words[i];
    float currentWidth = textWidth(currentLine + " " + word);
    if (currentWidth <= maxWidth) {
      currentLine += " " + word;
    } else {
      lines.add(currentLine);
      currentLine = word;
    }
  }
  lines.add(currentLine);

  return lines.toArray(new String[lines.size()]);
}
