# FingerDrawingView

FingerDrawingView is sub-class of UIView that enables finger drawing.

Feedback, comments, pull-requests are welcomed. 

## Usage 
1. Add the __QuartzCore__ framework to your project.
1. Add the view as a subview through Storyboard or programatically.
1. Start drawing!

The class also includes two useful methods:

```obj-c
-(UIImage *)imageOfDrawings;
```
Returns an image of the current drawings in the view. 

```obj-c
-(void)clearDrawings;
```
Erases all drawings from the view.

## To do

* Current implementation draws straight lines. A new smoother and curvy way should be implemented.
* Color!
