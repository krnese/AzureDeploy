"use strict";

var grunt = require('grunt');
require('load-grunt-tasks')(grunt);

var stripJsonComments = require("strip-json-comments");


var branch = process.env.sourcebranch;
var folder = grunt.option('folder') || branch || '.';

var stripSubFolder = '.stripped';   // subdirectory to hold comment-stripped json files which are validated.
var folderStripped = './' + stripSubFolder;

// before and after strip locations for the UI file
// Note: this file is expected in the root of the subtree for the solution templates.  i.e., directly in $folder.
var uiBasename = "createUIDefinition.json";
var sourceUI = `${folder}/${uiBasename}`;
var targetUI = `${stripSubFolder}/${uiBasename}`;

// The input source files to be stripped and copied to ${stripSubFolder}
// Note: file paths below are written assuming pwd is the root of the Solution Template's subdirectory tree.
var solutionInitialJsonFiles = [
    `./**/*.json`,                  // all of the JSON files in the directory tree
    `!./**/node_modules/**/*.json`  // less any of the files that are really part of grunt 
];

grunt.initConfig({

    // Clean out the stripped subdirectory before it's repopulated (later)
    clean: grunt.file.delete(`${folderStripped}`),

    // a function to call later which will load the (stripped) UI file and validate that it's at least valid JSON.
    // Note: this is set up as a function rather than a direct value because we want to delay reading the file
    // until after it's been comment stripped.
    uidef: function () {
        return grunt.file.readJSON(targetUI);
    },

    fileExists: {   // every AMP solution must have a top-level mainTemplate.json template, createUIDefinition,json, parameters file for validation and parameters file for deployment testing
        mainTemplate: [`${folder}/mainTemplate.json`],
        validateParams: [`${folder}/mainTemplate.validateparameters.json`],
        deployParmas: [`${folder}/mainTemplate.deployparameters.json`],
        UIDefinition: [sourceUI]
    },

    stripJsonComments: { // Make comment-stripped copies of each JSON file under $folder in the stripped subdirectory
        allJson: {
            options: {
                whitespace: true
            },
            expand: true,
            src: grunt.file.expand({ cwd: `${folder}` }, solutionInitialJsonFiles),
            cwd: `${folder}`,
            dest: `${folderStripped}/`
        }
    },

    jsonlint: {  // validating that files contain syntactically valid JSON (no schema used)
        allJson: {
            src: [`${stripSubFolder}/**/*.json`]
        },
        options: {  // set a readable message format 
            formatter: 'msbuild',
        }
    },

    "tv4": {  // validation of JSON files, with schema
        options: {
            multi: true,
            banUnknownProperties: true,
            fresh: true
        },
        validateUI: {   // just the UI file
            options: {
                root: 'https://schema.management.azure.com/schemas/<%= uidef().version %>/CreateUIDefinition.MultiVm.json#',
            },
            src: [targetUI]
        },
        validateARM: {  // all ARM templates (excluding the UI file)
            options: {
                root: "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
            },
            src: [`${stripSubFolder}/**/*.json`, `!${targetUI}`]
        }
    }
});

//======================================================================
// Set up the specific tasks
//======================================================================

var taskList = ["fileExists", "stripJsonComments", "jsonlint", "tv4:validateUI"];



// both task tags are equivalent.  "test" left for compatability.
grunt.task.registerTask("test", taskList);
grunt.task.registerTask("default", taskList);

