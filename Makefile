APP = 
IPA = $(PWD)/LuaLander.ipa
TESTFLIGHT_RESULT = testflight_result.json

DEVELOPER_NAME = iPhone Developer: Toru Hisai (2LA63FS7DX)
PROVISIONING_PROFILE = wildercard.mobileprovision

API_TOKEN = $(shell cat API_TOKEN)
TEAM_TOKEN = $(shell cat TEAM_TOKEN)

testflight: $(TESTFLIGHT_RESULT)

$(IPA): $(APP) $(PROVISIONING_PROFILE)
	/usr/bin/xcrun \
  -sdk iphoneos PackageApplication -v \
  "$(APP)" \
  -o "$(IPA)" \
  --sign "${DEVELOPER_NAME}" \
  --embed "${PROVISIONING_PROFILE}"

$(TESTFLIGHT_RESULT): $(IPA)
	curl http://testflightapp.com/api/builds.json \
    -F file=@$(IPA) \
    -F api_token='$(API_TOKEN)' \
    -F team_token='$(TEAM_TOKEN)' \
    -F notes=@ChangeLog \
    -F notify=True \
    -F distribution_lists='lualander' \
	> $@
	cat $@
