# Pressletter
## A screenshot-scanning word finder for Loren Brichter's awesome [Letterpress](https://itunes.apple.com/us/app/letterpress-word-game/id526619424?mt=8) game.

I wrote this over a weekend last November right after Letterpress came out—I was addicted to the game and I'd never done any kind of OCR code before, so it seemed like a fun project. I'm open-sourcing it here (GPL license) in hopes that someone finds it interesting.

To use Pressletter, simply select a Letterpress screenshot from your device's camera roll (works with screenshots taken on iPhone 4, 5 and iPad in both Portrait and Landscape orientations) and it'll generate the 1000 longest words on the board. If you tap on letters on the board, Pressletter will re-sort the list weighting those letters more heavily.

Pressletter was written and tested against the 1.0 release of Letterpress. It appears to work with the current release 1.4 (though the dictionary may be out of sync with the shipping version of Letterpress)

### Caveat

This isn't production-ready code; I wrote it as a fun project and I only toyed with the idea of releasing it on the App Store very briefly (early solvers on the App Store made you enter the board manually) There are probably some bugs and some O(n^3) algorithms. Oh, and if you've ever played me in Letterpress, I promise I never used this against you. Honest. ;-)