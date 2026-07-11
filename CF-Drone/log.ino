// RAM日志记录
// In-RAM logging

#include "vector.h"
#include "util.h"

#include "board_config.h"

#define LOG_RATE 100
#define LOG_DURATION BOARD_LOG_DURATION  // 缓冲时长：C3=4秒（节省~22KB RAM）/ ESP32&S3=8秒
#define LOG_SIZE LOG_DURATION * LOG_RATE

Vector attitudeEuler;
Vector attitudeTargetEuler;

struct LogEntry {
	const char *name;
	float *value;
};

LogEntry logEntries[] = {
	{"t", &t},
	{"rates.x", &rates.x},
	{"rates.y", &rates.y},
	{"rates.z", &rates.z},
	{"ratesTarget.x", &ratesTarget.x},
	{"ratesTarget.y", &ratesTarget.y},
	{"ratesTarget.z", &ratesTarget.z},
	{"attitude.x", &attitudeEuler.x},
	{"attitude.y", &attitudeEuler.y},
	{"attitude.z", &attitudeEuler.z},
	{"attitudeTarget.x", &attitudeTargetEuler.x},
	{"attitudeTarget.y", &attitudeTargetEuler.y},
	{"attitudeTarget.z", &attitudeTargetEuler.z},
	{"thrustTarget", &thrustTarget}
};

const int logColumns = sizeof(logEntries) / sizeof(logEntries[0]);
float logBuffer[LOG_SIZE][logColumns];

void prepareLogData() {
	attitudeEuler = attitude.toEuler();
	attitudeTargetEuler = attitudeTarget.toEuler();
}

void logData() {
	if (!armed) return;
	static int logPointer = 0;
	static Rate period(LOG_RATE);
	if (!period) return;

	prepareLogData();

	for (int i = 0; i < logColumns; i++) {
		logBuffer[logPointer][i] = *logEntries[i].value;
	}

	logPointer++;
	if (logPointer >= LOG_SIZE) {
		logPointer = 0;
	}
}

void printLogHeader() {
	for (int i = 0; i < logColumns; i++) {
		print("%s%s", logEntries[i].name, i < logColumns - 1 ? "," : "\n");
	}
}

void printLogData() {
	for (int i = 0; i < LOG_SIZE; i++) {
		if (logBuffer[i][0] == 0) continue; // skip empty records
		for (int j = 0; j < logColumns; j++) {
			print("%g%s", logBuffer[i][j], j < logColumns - 1 ? "," : "\n");
		}
	}
}

// ====== 翻转调试文本日志（环形缓存，断电丢失，串口可导出）======
#define FLIP_LOG_SIZE 80
#define FLIP_LOG_LINE_LEN 120
static char flipLogBuf[FLIP_LOG_SIZE][FLIP_LOG_LINE_LEN];
static int flipLogHead = 0;

void flipLogPrint(const char* fmt, ...) {
	va_list args;
	va_start(args, fmt);
	vsnprintf(flipLogBuf[flipLogHead], FLIP_LOG_LINE_LEN, fmt, args);
	va_end(args);
	flipLogHead = (flipLogHead + 1) % FLIP_LOG_SIZE;
}

void printFlipLog() {
	print("===== 翻转日志 (最多%d条) =====\n", FLIP_LOG_SIZE);
	for (int i = 0; i < FLIP_LOG_SIZE; i++) {
		int idx = (flipLogHead + i) % FLIP_LOG_SIZE;
		if (flipLogBuf[idx][0] != '\0') {
			print("%s", flipLogBuf[idx]);
		}
	}
}
