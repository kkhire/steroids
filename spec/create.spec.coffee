TestHelper = require "./test_helper"

describe 'create', ->

  describe "new app", ->

    beforeEach =>
      @testHelper = new TestHelper
      @testHelper.bootstrap()
      @testHelper.changeToWorkingDirectory()

    afterEach =>
      @testHelper.cleanUp()

    # it 'should be created', =>
    #   session = @testHelper.run
    #     args: ["create", "myApp"]
    #     debug: true
    #
    #   runs =>
    #     fs = require "fs"
    #
    #     expect( session.code ).toBe(0)
    #     expect( fs.existsSync "myApp" ).toBe true

    it 'should be not overwrite', =>
      fs = require "fs"

      fs.mkdirSync "importantDirectory"
      expect( fs.existsSync "importantDirectory" ).toBe true

      session = @testHelper.run
        args: ["create", "importantDirectory"]

      runs =>
        expect( session.code ).toBe(1)
        expect( session.stderr ).toMatch "Directory importantDirectory already exists"

  describe 'steroids²', ->

    beforeEach =>
      @testHelper = new TestHelper
      @testHelper.prepare()

    describe "structure", =>
      path = require "path"
      fs = require "fs"

      beforeEach =>
        @testAppPath = @testHelper.testAppPath

        @readContentsSync = (basePath, fileName) ->
          fullPath = path.join(basePath, fileName)
          fs.readFileSync(fullPath).toString()

      describe "root", =>

        it "has .gitignore with dist", =>
          expect(@readContentsSync(@testAppPath, ".gitignore"))
          .toMatch(/dist/)

        it "has package.json with dependencies", =>
          expect(@readContentsSync(@testAppPath, "package.json"))
          .toMatch(/"private": true,/)

        it "has bower.json with dependencies", =>
          expect(@readContentsSync(@testAppPath, "bower.json"))
          .toMatch(/dependencies": {/)

        it "has Gruntfile.coffee with grunt.loadNpmTasks", =>
          expect(@readContentsSync(@testAppPath, "Gruntfile.coffee"))
          .toMatch(/grunt.loadNpmTasks/)

      describe "app", =>

        beforeEach =>
          @appPath = path.join @testHelper.testAppPath, "app"
          @appCommonPath = path.join @appPath, "common"
          @appCommonViewsPath = path.join @appCommonPath, "views"

        it "has common/index.coffee with 'supersonic'", =>
          expect(@readContentsSync(@appCommonPath,"index.coffee"))
          .toMatch(/'supersonic'/)

        it "has common/views/getting-started.html with a greeting", =>
          expect(@readContentsSync(@appCommonViewsPath,"getting-started.html"))
          .toMatch(/Awesome! This file is located at/)

      describe "config", =>

        beforeEach =>
          @configPath = path.join @testHelper.testAppPath, "config"

        it "has app.coffee with 'name: \"__testApp\"'", =>
          expect(@readContentsSync(@configPath,"app.coffee"))
          .toMatch(/name: "__testApp"/)

        it 'has structure.coffee with \'location: "common#getting-started"\'', =>
          expect(@readContentsSync(@configPath,"structure.coffee"))
          .toMatch(/location: "common#getting-started"/)
