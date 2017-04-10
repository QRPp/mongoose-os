MGOS_ENABLE_ARDUINO_API ?= 0
MGOS_ENABLE_ATCA ?= 1
MGOS_ENABLE_ATCA_SERVICE ?= 1
MGOS_ENABLE_AWS_SHADOW ?= 1
MGOS_ENABLE_BITBANG ?= 1
MGOS_ENABLE_CONSOLE ?= 0
MGOS_ENABLE_CONSOLE_FILE_BUFFER ?= 0
MGOS_ENABLE_CONFIG_SERVICE ?= 1
MGOS_ENABLE_DEBUG_UDP ?= 1
MGOS_ENABLE_DNS_SD ?= 1
MGOS_ENABLE_FILE_UPLOAD ?= 0
MGOS_ENABLE_FILESYSTEM_SERVICE ?= 1
MGOS_ENABLE_GPIO_SERVICE ?= 1
MGOS_ENABLE_HTTP_SERVER ?=1
MGOS_ENABLE_I2C ?= 1
MGOS_ENABLE_I2C_GPIO ?= 0
MGOS_ENABLE_I2C_SERVICE ?= 1
MGOS_ENABLE_MQTT ?= 1
MGOS_ENABLE_RPC ?= 1
MGOS_ENABLE_RPC_CHANNEL_HTTP ?= 1
MGOS_ENABLE_RPC_CHANNEL_MQTT ?= 1
MGOS_ENABLE_RPC_CHANNEL_UART ?= 1
MGOS_ENABLE_RPC_CHANNEL_WS ?= 1
MGOS_ENABLE_SNTP ?= 1
MGOS_ENABLE_SYS_SERVICE ?= 1
MGOS_ENABLE_UPDATER ?= 1
MGOS_ENABLE_UPDATER_POST ?= 1
MGOS_ENABLE_UPDATER_RPC ?= 1
MGOS_ENABLE_WEB_CONFIG ?= 0
MGOS_ENABLE_WIFI ?= 1

MGOS_DEBUG_UART ?= 0
MGOS_EARLY_DEBUG_LEVEL ?= LL_INFO
MGOS_SRCS += mgos_debug.c

MGOS_FEATURES += -DMGOS_DEBUG_UART=$(MGOS_DEBUG_UART) \
                 -DMGOS_EARLY_DEBUG_LEVEL=$(MGOS_EARLY_DEBUG_LEVEL) \
                 -DMG_ENABLE_CALLBACK_USERDATA

SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_http_config.yaml

ifeq "$(MGOS_ENABLE_CONSOLE)" "1"
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_console_config.yaml
  MGOS_SRCS += mgos_console.c cs_frbuf.c
  MGOS_FEATURES += -DMGOS_ENABLE_CONSOLE=1
else
  MGOS_FEATURES += -DMGOS_ENABLE_CONSOLE=0
endif

ifeq "$(MGOS_ENABLE_ARDUINO_API)" "1"
  MGOS_FEATURES += -DARDUINO=150 -DMGOS_ENABLE_ARDUINO_API=1
  MGOS_SRCS += $(notdir $(wildcard $(MGOS_SRC_PATH)/Arduino/*.c*))
  IPATH += $(MGOS_SRC_PATH)/Arduino
  VPATH += $(MGOS_SRC_PATH)/Arduino
endif

ifeq "$(MGOS_ENABLE_ATCA)" "1"
  ATCA_PATH ?= $(MGOS_PATH)/third_party/cryptoauthlib
  ATCA_LIB = $(BUILD_DIR)/libatca.a

  MGOS_SRCS += mgos_atca.c
  MGOS_FEATURES += -DMGOS_ENABLE_ATCA -I$(ATCA_PATH)/lib
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_atca_config.yaml

  ifeq "$(MGOS_ENABLE_RPC)$(MGOS_ENABLE_ATCA_SERVICE)" "11"
    MGOS_SRCS += mgos_atca_service.c
    MGOS_FEATURES += -DMGOS_ENABLE_ATCA_SERVICE
  else
    MGOS_FEATURES += -DMGOS_ENABLE_ATCA_SERVICE=0
  endif

$(BUILD_DIR)/atca/libatca.a:
	$(Q) mkdir -p $(BUILD_DIR)/atca
	$(Q) make -C $(ATCA_PATH)/lib \
		CC=$(CC) AR=$(AR) BUILD_DIR=$(BUILD_DIR)/atca \
	  CFLAGS="$(CFLAGS)"

$(ATCA_LIB): $(BUILD_DIR)/atca/libatca.a
	$(Q) cp $< $@
	$(Q) $(OBJCOPY) --rename-section .rodata=.irom0.text $@
	$(Q) $(OBJCOPY) --rename-section .rodata.str1.1=.irom0.text $@
else
  ATCA_LIB =
  MGOS_FEATURES += -DMGOS_ENABLE_ATCA=0
endif

ifeq "$(MGOS_ENABLE_AWS_SHADOW)$(MGOS_ENABLE_MQTT)" "11"
  MGOS_SRCS += mgos_aws_shadow.c
  MGOS_FEATURES += -DMGOS_ENABLE_AWS_SHADOW=1
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_aws_shadow_config.yaml
endif

ifeq "$(MGOS_ENABLE_DEBUG_UDP)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_DEBUG_UDP=1
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_debug_udp_config.yaml
endif

ifeq "$(MGOS_ENABLE_BITBANG)" "1"
  MGOS_SRCS += mgos_bitbang.c
  MGOS_FEATURES += -DMGOS_ENABLE_BITBANG=1
endif

ifeq "$(MGOS_ENABLE_RPC)" "1"
  MGOS_SRCS += mg_rpc.c mgos_rpc.c
  MGOS_FEATURES += -DMGOS_ENABLE_RPC
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_rpc_config.yaml

ifeq "$(MGOS_ENABLE_CONFIG_SERVICE)" "1"
  MGOS_SRCS += mgos_service_config.c
  MGOS_FEATURES += -DMGOS_ENABLE_CONFIG_SERVICE
endif
ifeq "$(MGOS_ENABLE_FILESYSTEM_SERVICE)" "1"
  MGOS_SRCS += mgos_service_filesystem.c
  MGOS_FEATURES += -DMGOS_ENABLE_FILESYSTEM_SERVICE
endif
ifeq "$(MGOS_ENABLE_GPIO_SERVICE)" "1"
  MGOS_SRCS += mgos_gpio_service.c
  MGOS_FEATURES += -DMGOS_ENABLE_GPIO_SERVICE
endif
ifeq "$(MGOS_ENABLE_I2C)$(MGOS_ENABLE_I2C_SERVICE)" "11"
  MGOS_SRCS += mgos_i2c_service.c
  MGOS_FEATURES += -DMGOS_ENABLE_I2C_SERVICE
endif
ifeq "$(MGOS_ENABLE_SYS_SERVICE)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_SYS_SERVICE
endif
ifeq "$(MGOS_ENABLE_RPC_CHANNEL_HTTP)" "1"
  MGOS_SRCS += mg_rpc_channel_http.c
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_HTTP
endif
ifeq "$(MGOS_ENABLE_RPC_CHANNEL_MQTT)" "1"
  MGOS_SRCS += mgos_rpc_channel_mqtt.c
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_MQTT
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_rpc_channel_mqtt_config.yaml
else
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_MQTT=0
endif
ifeq "$(MGOS_ENABLE_RPC_CHANNEL_UART)" "1"
  MGOS_SRCS += mgos_rpc_channel_uart.c
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_UART
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_rpc_channel_uart_config.yaml
endif
ifeq "$(MGOS_ENABLE_RPC_CHANNEL_WS)" "1"
  MGOS_SRCS += mg_rpc_channel_ws.c
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_WS
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_rpc_channel_ws_config.yaml
else
  MGOS_FEATURES += -DMGOS_ENABLE_RPC_CHANNEL_WS=0
endif

endif # MGOS_ENABLE_RPC

ifeq "$(MGOS_ENABLE_DNS_SD)" "1"
  MGOS_SRCS += mgos_mdns.c mgos_dns_sd.c
  MGOS_FEATURES += -DMG_ENABLE_DNS -DMG_ENABLE_DNS_SERVER -DMGOS_ENABLE_MDNS -DMGOS_ENABLE_DNS_SD
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_dns_sd_config.yaml
endif

ifeq "$(MGOS_ENABLE_I2C)" "1"
  MGOS_SRCS += mgos_i2c.c
  MGOS_FEATURES += -DMGOS_ENABLE_I2C
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_i2c_config.yaml
  ifeq "$(MGOS_ENABLE_I2C_GPIO)" "1"
    MGOS_SRCS += mgos_i2c_gpio.c
    MGOS_FEATURES += -DMGOS_ENABLE_I2C_GPIO
    SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_i2c_gpio_config.yaml
  endif
endif

ifeq "$(MGOS_ENABLE_MQTT)" "1"
  MGOS_SRCS += mgos_mqtt.c
  MGOS_FEATURES += -DMGOS_ENABLE_MQTT -DMG_ENABLE_MQTT
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_mqtt_config.yaml
else
  MGOS_FEATURES += -DMG_ENABLE_MQTT=0
endif

ifeq "$(MGOS_ENABLE_SNTP)" "1"
  MGOS_SRCS += mgos_sntp.c
  MGOS_FEATURES += -DMG_ENABLE_SNTP -DMGOS_ENABLE_SNTP
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_sntp_config.yaml
endif

ifeq "$(MGOS_ENABLE_UPDATER)" "1"
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_updater_config.yaml
  MGOS_SRCS += mgos_updater_common.c mgos_updater_http.c
  MGOS_FEATURES += -DMGOS_ENABLE_UPDATER=1
ifeq "$(MGOS_ENABLE_UPDATER_POST)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_UPDATER_POST=1
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_updater_post.yaml
endif
ifeq "$(MGOS_ENABLE_UPDATER_RPC)" "1"
  MGOS_SRCS += mgos_updater_rpc.c
  MGOS_FEATURES += -DMGOS_ENABLE_UPDATER_RPC=1
endif
endif

ifeq "$(MGOS_ENABLE_WIFI)" "1"
  SYS_CONF_SCHEMA += $(MGOS_SRC_PATH)/mgos_wifi_config.yaml
  MGOS_SRCS += mgos_wifi.c
  MGOS_FEATURES += -DMGOS_ENABLE_WIFI=1
else
  MGOS_FEATURES += -DMGOS_ENABLE_WIFI=0
endif

ifeq "$(MGOS_ENABLE_HTTP_SERVER)" "0"
  MGOS_FEATURES += -DMGOS_ENABLE_HTTP_SERVER=0
else
  MGOS_FEATURES += -DMGOS_ENABLE_HTTP_SERVER=1
endif

ifeq "$(MGOS_ENABLE_WEB_CONFIG)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_WEB_CONFIG=1
endif

ifeq "$(MGOS_ENABLE_FILE_UPLOAD)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_FILE_UPLOAD=1
endif

ifeq "$(MGOS_ENABLE_CONSOLE_FILE_BUFFER)" "1"
  MGOS_FEATURES += -DMGOS_ENABLE_CONSOLE_FILE_BUFFER=1
endif

# Export all the feature switches.
# This is required for needed make invocations (i.e. ESP32 IDF)
export MGOS_ENABLE_ARDUINO_API
export MGOS_ENABLE_ATCA
export MGOS_ENABLE_ATCA_SERVICE
export MGOS_ENABLE_AWS_SHADOW
export MGOS_ENABLE_BITBANG
export MGOS_ENABLE_CONFIG_SERVICE
export MGOS_ENABLE_CONSOLE
export MGOS_ENABLE_DEBUG_UDP
export MGOS_ENABLE_DNS_SD
export MGOS_ENABLE_FILESYSTEM_SERVICE
export MGOS_ENABLE_GPIO_SERVICE
export MGOS_ENABLE_I2C
export MGOS_ENABLE_I2C_GPIO
export MGOS_ENABLE_MQTT
export MGOS_ENABLE_RPC
export MGOS_ENABLE_RPC_CHANNEL_HTTP
export MGOS_ENABLE_RPC_CHANNEL_MQTT
export MGOS_ENABLE_RPC_CHANNEL_UART
export MGOS_ENABLE_SNTP
export MGOS_ENABLE_SYS_SERVICE
export MGOS_ENABLE_UPDATER
export MGOS_ENABLE_UPDATER_POST
export MGOS_ENABLE_UPDATER_RPC
export MGOS_ENABLE_WIFI
export MGOS_ENABLE_HTTP_SERVER