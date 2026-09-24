import processing.serial.*;
import org.gamecontrolplus.*;
import ddf.minim.*;
import hypermedia.net.*;
import controlP5.*;

//無線受信用変数
UDP udp1, udp2;
//final String IP = "localhost";
final String IP = "192.168.1.3";
final int PORT = 2000;
int udpsig1 = 0, udpsig2 = 0;
//コントローラー用変数
  ControlIO control;
  ControlDevice device1, device2;
  ControlButton button1, button2;
  ControlButton button1_A, button1_X, button1_B, button1_Y, button1_ZR, button2_left, button2_up, button2_down, button2_right, button2_ZL;
  int button_c = 0;
  int right1, right2, left1, left2, down1, down2, Z1, Z2;
//画像用変数
  PImage background, subbackground, player1, player2, player1_attack, player2_attack, player1_defense, player2_defense;
//Arduino
  Serial myPort;
  int val, reserve = 0;
  int signal1;
//初期設定変数
  int ground = 878, chara = 370, attack_delay = 50;
  //画像自体は470ピクセル
//変動変数
  int figure1 = 0, figure2 = 0, position1, position2, distance, attack_time1 = 0, attack_time2 = 0, guarding_time1 = 0, guarding_time2 = 0, playing_mode = 0, delay_time = 301, winner_number = 0, defense_time1 = 630, defense_time2 = 630;
  int score1 = 0, score2 = 0, mode = 0, sig_attack1 = 0, sig_attack2 = 0, sig_defense1 = 0, sig_defense2 = 0, round = 0, game = 1, time_i = 0, reset = 0, guard_count1 = 0, guard_count2 = 0, rea = 0, rea1 = -180;
  int finish_minim = 0;
//効果音・BGM用変数
Minim minim;
AudioPlayer play1, play2, play3, play4, play5, play6, play7, play8;
//タイトル用
PFont font;
int lettersCount = 7;
float[] xOffsets = new float[lettersCount];
float[] yOffsets = new float[lettersCount];
float[] targetX = new float[lettersCount];
float[] targetY = new float[lettersCount];
boolean[] isJoined = new boolean[lettersCount];

void setup() {
  //frameRate(45); 
   
//タイトル用
  font = createFont("NotoSerifJP-Regular.ttf", 100); // 和風フォントを指定
  textFont(font);
  textSize(300);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < lettersCount; i++) {
    xOffsets[i] = random(-800, 800);
    yOffsets[i] = random(-800, 800);
    targetX[i] = width / 2 + (i - lettersCount / 2) * textWidth("A");
    targetY[i] = height / 3;
    isJoined[i] = false;
  }
  
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 2400);
  
  udp1 = new UDP(this, 2000/*,"192.168.1.6"*/);
  udp1.listen( true );
  udp2 = new UDP(this, 2001);
  udp2.listen(true);
  
  
  position1 = 0;
  position2 = width - 470;
  fullScreen();
  background = loadImage("和風ステージ背景.jpg"); // 画像を読み込む
  subbackground = loadImage("背景下部.png");
  player1 = loadImage("侍(右).png");
  player2 = loadImage("侍(左).png");
  player1_attack = loadImage("切りつけ(右).png");
  player2_attack = loadImage("切りつけ(左).png");
  player1_defense = loadImage("防御(右).png");
  player2_defense = loadImage("防御(左).png");
  println(width);
  println(height);
  control = ControlIO.getInstance(this);
  println("使えるデバイス: " + control.getDevices());
  /*device1 = control.getDevice(11);//使うのは0番目（getDevice(0)でも大丈夫）
  device2 = control.getDevice(10);
  button1_A = device1.getButton(0);
  button1_X = device1.getButton(1);
  button1_B = device1.getButton(2);
  button1_Y = device1.getButton(3);
  button1_ZR = device1.getButton(15);
  button2_left = device2.getButton(0);
  button2_up = device2.getButton(2);
  button2_down = device2.getButton(1);
  button2_right = device2.getButton(3);
  button2_ZL = device2.getButton(15);*/
  minim = new Minim(this);
  play1 = minim.loadFile("剣の素振り2.mp3");
  play2 = minim.loadFile("剣で打ち合う1.mp3");
  play3 = minim.loadFile("居合抜き1.mp3");
  play4 = minim.loadFile("ほら貝を吹き鳴らす.mp3");
  play5 = minim.loadFile("男衆「始めいッ！」.mp3");
  play6 = minim.loadFile("歓声と拍手.mp3");
  play7 = minim.loadFile("決定ボタンを押す47.mp3");
  play8 = minim.loadFile("Melody_of_the_Festival.mp3");
  PFont font = createFont("Meiryo", 50);
  textFont(font);
}

void draw() {
    if(myPort.available() > 0){
      val = myPort.read();
      println(val);
    }
//ボタン設定
  /*if(button2_left.pressed()) left1 = 1; else left1 = 0;
  if(button1_Y.pressed()) left2 = 1; else left2 = 0;
  if(button2_right.pressed()) right1 = 1; else right1 = 0;
  if(button1_A.pressed()) right2 = 1; else right2 = 0;
  if(button2_down.pressed()) down1 = 1; else down1 = 0;
  if(button1_B.pressed()) down2 = 1; else down2 = 0;
  if(button2_ZL.pressed()) Z1 = 1; else Z1 = 0;
  if(button1_ZR.pressed()) Z2 = 1; else Z2 = 0;*/
  
  if(((udpsig1 & 1) == 1)) Z1 = 1; else Z1 = 0;
  if((udpsig2 & 1) == 1) Z2 = 1; else Z2 = 0;
  if((val & 1) == 1) left1 = 1; else left1 = 0;
  if((val & 2) == 2) right1 = 1; else right1 = 0;
  if((val & 4) == 4) right2 = 1; else right2 = 0;
  if((val & 8) == 8) left2 = 1; else left2 = 0;
  if((udpsig1 & 2) == 2) down1 = 1;
  if((udpsig1 & 2) == 0) down1 = 0;
  if((udpsig2 & 2) == 2) down2 = 1;
  if((udpsig2 & 2) == 0) down2 = 0;
  

//タイトル画面
  if(game == 0){
    image(background, 0, 0);
  fill(255);
  for (int i = 0; i < lettersCount; i++) {
    float x = targetX[i] + xOffsets[i];
    float y = targetY[i] + yOffsets[i];
    textSize(200);
    text("SAMURAI".charAt(i), x, y);
    
    // ぶつかる処理
    if (!isJoined[i]) {
      float distToTarget = dist(x, y, targetX[i], targetY[i]);
      if (distToTarget < 10) {
        isJoined[i] = true; // 近づいたら合体
        xOffsets[i] = 0; // 移動を止める
        yOffsets[i] = 0; // 移動を止める
      } else {
        // ターゲットに向かって移動
        xOffsets[i] += (targetX[i] - x) * 0.1; // ぶつかりながら移動
        yOffsets[i] += (targetY[i] - y) * 0.1; // ぶつかりながら移動
      }
    }
  }
  
  // 文字が合体したら、さらにスケールする
  if (all(isJoined)) {
    for (int i = 0; i < lettersCount; i++) {
      xOffsets[i] = 0;
      yOffsets[i] = 0;
    }
    scale(1.5);
  }
  if(Z1 == 1 || Z2 == 2) game = 1;
    
//ゲーム画面
  } else if(game == 1){
    //if((udpsig & 4) && (udpsig & 1)) sig_attack1 = 1;
    /*signal1 = 0;
    //signal2 = 0;*/
    if(delay_time >= 1) delay_time -= 1;
    distance = position2 - position1;
    background(255); // 背景を白に設定
    if(attack_time1 > 0) attack_time1 -= 1;
    if(attack_time2 > 0) attack_time2 -= 1;
    if(guarding_time1 > 0) guarding_time1 -= 1;
    if(guarding_time2 > 0) guarding_time2 -= 1;
    image(background, 0, 0); // 画像を(0, 0)の位置に描画
    /*if(Z2 == 1 && button_c == 0){
      figure1 += 1;
      button_c = 1;
    }
    if(Z1 == 1 && button_c == 0){
      figure2 += 1;
      button_c = 1;
    }*/
    if(figure1 == 0){
      image(player1, position1, ground-chara);
    } else if(figure1 == 1){
      image(player1_attack, position1, ground-chara);
    } else {
      image(player1_defense, position1, ground-chara);
    }
    if(figure2 == 0){
      image(player2, position2, ground-chara);
    } else if(figure2 == 1){
      image(player2_attack, position2, ground-chara);
    } else {
      image(player2_defense, position2, ground-chara);
    }
    if(figure1 == 3) figure1 = 0;
    if(figure2 == 3) figure2 = 0;
    //rect(500, ground - chara, chara, chara);
    /*if(!(Z2 == 1) && !(Z1 == 1) && button_c == 1){
      button_c = 0;
    }*/
    image(subbackground, 0, 0);
      
    if(delay_time == 300 && (score1 >= 5 || score2 >= 5)){
      delay_time = 1000;
      mode = 1;
    }else if(delay_time <= 100){
      if(attack_time2 == 0){
        if(down2 == 1 && defense_time2 > 270){guarding_time2 = 1; defense_time2 -= 2;}
        if(guarding_time2 == 0){
          if(right2 == 1 && position2 < width - 470) position2 += 10;
          if(left2 == 1) if(distance >= 65) position2 -= 10;
        }
      }
      if(attack_time1 == 0){
        if(down1 == 1 && defense_time1 > 270) 
        //if(defense_time1 > 270 && sig_attack1 == 1)
          {guarding_time1 = 1; defense_time1 -= 2;}
        if(guarding_time1 == 0){
          if(right1 == 1)if(distance >= 65) position1 += 10;
          if(left1 == 1 && position1 > 0) position1 -= 10;
        }
      }
      if(Z2 == 1 && attack_time2 == 0) attack_time2 = attack_delay;
      if(Z1 == 1 && attack_time1 == 0) attack_time1 = attack_delay;
    }
    if(attack_time1 == attack_delay && distance <= 225 && guarding_time2 == 0){
      delay_time = 500;
      play8.pause();
      winner_number = 1;
      play3.rewind();
      play3.play();
      score1 += 1;
    } 
    if(attack_time2 == attack_delay && distance <= 225 && guarding_time1 == 0){
      delay_time = 500;
      play8.pause();
      play3.rewind();
      play3.play();
      if(winner_number == 1){
      winner_number = 3;
        score1 -= 1;
      } else if(winner_number == 0){
        winner_number = 2;
        score2 += 1;
      }
    }
    if(attack_time2 == attack_delay && distance <= 225 && guarding_time1 > 0 || attack_time1 == attack_delay && distance <= 225 && guarding_time2 > 0){
      play2.rewind();
      play2.play();
      if(attack_time1 == attack_delay) guard_count2++; else guard_count1++;
    }
    if((attack_time1 == attack_delay || attack_time2 == attack_delay) && distance > 225){
      play1.rewind();
      play1.play();
    }
    if(guarding_time1 > 0){
      figure1 = 2;
    }else if(attack_time1 > 0){
      figure1 = 1;
    } else if(attack_time1 == 0){
      figure1 = 0;
    }
    if(guarding_time2 > 0){
      figure2 = 2;
    }else if(attack_time2 > 0){
      figure2 = 1;
    } else if(attack_time2 == 0){
      figure2 = 0;
    }
    textSize(80);
    textAlign(CENTER, CENTER);
    if(delay_time >= 1 && mode == 1){
      textSize(100);
      textAlign(CENTER, CENTER);
      fill(255);
      text("FINISH!", width/2, height/3);
      text(score1 * 40 + guard_count1 * 10 + "pt", width / 4, height / 4);
      text(score2 * 40 + guard_count2 * 10 + "pt", 3 * width / 4, height / 4);
      textSize(80);
      if(delay_time == 1000 && finish_minim == 0){
        play6.rewind();
        play6.play();
        finish_minim = 1;
      }
    } else if(delay_time > 300){
      if(winner_number == 1) {text("PLAYER1 WINNER", width/2, height/3);}
      if(winner_number == 2) {text("PLAYER2 WINNER", width/2, height/3);}
      if(winner_number == 3) {text("DRAW!", width/2, height/3); if(rea == 0)rea = 1;}
    } else if(delay_time < 300 && delay_time > 100){
      text("第"+round+"ラウンド", width/2, height /3);
    } else if(delay_time > 0 && delay_time < 100){
      text("始めい！", width/2, height /3);
    } else if(delay_time == 100){
      play5.rewind();
      play5.play();
      play8.rewind();
      play8.play();
    } else if(delay_time == 300){
      round += 1;
      play4.rewind();
      play4.play();
    }
    
    textAlign(LEFT);
    text(score1 + "勝\n" + guard_count1 + "ガード", 10, 100);
    textAlign(RIGHT);
    text(score2 + "勝\n" + guard_count2 + "ガード", width -10 , 100);
    textAlign(CENTER, CENTER);
    fill(255);
    arc(position1 - 50, 600, 100, 100, radians(0), radians(360));
    arc(position2 + 520, 600, 100, 100, radians(0), radians(360));
    fill(100);
    arc(position1 - 50, 600, 80, 80, radians(0), radians(360));
    arc(position2 + 520, 600, 80, 80, radians(0), radians(360));
    fill(0, 200, 255);
    arc(position1 - 50/* - 50*/, 600, 80, 80, radians(270), radians(defense_time1));
    arc(position2 + 520/* + 520*/, 600, 80, 80, radians(270), radians(defense_time2));
    fill(255);
    arc(position1 - 50, 600, 10, 10, radians(0), radians(360));
    arc(position2 + 520, 600, 10, 10, radians(0), radians(360));
    if(delay_time == 300){position1 = 150; position2 = width - 470 - 150; winner_number = 0;}
    if(udpsig1 > 0 || udpsig2 > 0) println(udpsig1 + " " + udpsig2);
    //udpsig1 = 0;
    //udpsig2 = 0;
  }
  if(rea == 1){
    if(rea1 == -180){
      play7.rewind();
      play7.play();
    }
    fill(255, 255, 0);
    rect(width/2 - 400, rea1 - 130, 800, 300);
    fill(0);
    rect(width/2 - 395, rea1 - 125, 790, 290);
    fill(255, 255, 0);
    text("<称号>\n息の合う好敵手", width / 2, rea1);
    fill(255);
    if(rea1 == 160)rea = 2;
    rea1 += 4;
  } else if(rea == 2){ 
    fill(255, 255, 0);
    rect(width/2 - 400, 30, 800, 300);
    fill(0);
    rect(width/2 - 395, 35, 790, 290);
    fill(255, 255, 0);
    text("<称号>\n息の合う好敵手", width / 2, 160);
    fill(255);
    rea1++;
    if(rea1 == 240){
      rea1 = 160;
      rea = 3;
    }
  } else if(rea == 3){ 
    fill(255, 255, 0);
    rect(width/2 - 400, rea1 - 130, 800, 300);
    fill(0);
    rect(width/2 - 395, rea1 - 125, 790, 290);
    fill(255, 255, 0);
    text("<称号>\n息の合う好敵手", width / 2, rea1);
    fill(255);
    rea1 -= 4;
    if(rea1 == -180)rea = 4;
  }
  val = 0;
  reset = 0;
  //position2 -= 2;
  //position1 += 2;
  //println(delay_time);
}

void receive( byte[] data, String ip, int port ) {
  final String TARGET_IP1 = "192.168.1.6"; // 例: デバイス1のIP
  final String TARGET_IP2 = "192.168.1.13"; // 例: デバイス2のIP

  // 受信元IPアドレスに基づく処理
  if (ip.equals(TARGET_IP1)) {
    udpsig1 = int(data[0]);
  } else if (ip.equals(TARGET_IP2)) {
    udpsig2 = int(data[0]);
  }
}

boolean all(boolean[] array) {
  for (boolean value : array) {
    if (!value) return false;
  }
  return true;
}

void keyPressed(){
  if(keyCode == ENTER && delay_time >= 1 && mode == 1){
    mode = 0;
    game = 0;
    score1 = 0;
    score2 = 0;
    delay_time = 301;
    position1 = 0;
    position2 = width - 470;
    round = 0;
    defense_time1 = 630;
    defense_time2 = 630;
    rea = 0;
    rea1 = -180;
    finish_minim = 0;
  }
  if(key == '~'){
    defense_time1 = 630;
    defense_time2 = 630; 
  }
  if(key == 'r')rea = 1;
  if(key == 'A')Z2 = 1;
}
void stop() {
  play1.close();
  play2.close();
  play3.close();
  play4.close();
  play5.close();
  minim.stop();
  super.stop();
}
