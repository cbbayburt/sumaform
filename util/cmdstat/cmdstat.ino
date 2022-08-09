#define GREEN_LED 5
#define RED_LED 3
#define RESET_BTN 6

// LED brightness
#define L_ON 40
#define L_OFF LOW

// Terraform state
int state = 0; // 0: init, 1: running, 2: finished, 3: disconnected
boolean result = false;

// Blink LED
int ledState = L_OFF;
unsigned long curMillis = 0;
unsigned long prevMillis = 0;
const long interval = 500;

// Heartbeat
boolean initready = false;
unsigned long heartbeat;


void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  pinMode(RESET_BTN, INPUT_PULLUP);

  Serial.begin(9600);
  while (!Serial) {
    ;
  }
}

void blinkLed(int ledPin) {
  if (curMillis - prevMillis >= interval) {
    prevMillis = curMillis;
    ledState = ledState == L_OFF ? L_ON : L_OFF;
    analogWrite(ledPin, ledState);
  }
}

void loop() {
  curMillis = millis();

  // Reset event
  if (digitalRead(RESET_BTN) == LOW && state == 2) {
    state = 0;
  }

  if (initready && (curMillis - heartbeat < 1000)) {
    digitalWrite(LED_BUILTIN, HIGH);
  } else {
    // Not listening, idle
    digitalWrite(LED_BUILTIN, LOW);
    state = 0;
  }

  if (state == 0) {
    // Listening
    analogWrite(GREEN_LED, L_OFF);
    analogWrite(RED_LED, L_OFF);
  } else if (state == 1) {
    // Running
    blinkLed(GREEN_LED);
    analogWrite(RED_LED, L_OFF);
  } else if (state == 2) {
    // Finished
    if (result) {
      analogWrite(GREEN_LED, L_ON);
      analogWrite(RED_LED, L_OFF);
    } else {
      analogWrite(GREEN_LED, L_OFF);
      analogWrite(RED_LED, L_ON);
    }
  }

  delay(10);
}

void serialEvent() {
  while (Serial.available() > 0) {
    char inChar = (char)Serial.read();

    if (inChar == 'S') {
      state = 1;
    } else if (inChar == 'T') {
      state = 2;
      result = true;
    } else if (inChar == 'F') {
      state = 2;
      result = false;
    }
    initready = true;
    heartbeat = millis();
  }
}
