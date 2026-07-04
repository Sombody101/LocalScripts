#!/bin/bash
flyline mouse --mode disabled
flyline set-cursor --effect blink

flyline key bind Down tabCompletionAvailable=tabCompletionNextSuggestion
flyline key bind Up tabCompletionAvailable=tabCompletionPrevSuggestion
flyline key bind Tab tabCompletionAvailable=tabCompletionAcceptEntry

flyline key bind Ctrl+Left always=moveLeftOneWordPart
flyline key bind Ctrl+Right always=moveRightOneWordPart
flyline key bind Alt+Left always=moveLeftOneWord
flyline key bind Alt+Right always=moveRightOneWord