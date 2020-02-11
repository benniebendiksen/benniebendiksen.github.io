Building a Custom Visualization

---

When it comes to visualizing samples, the challenges users face when trying to make judgements about probabilistic data generated through samples has been noted.

The following encapsulates an example involving random draws from the normal distribution under differing parameters (mean and standard deviation); each draw is set to represent a sample of some population from a different year.

A challenge that users face is that, for a given y-axis value (e.g. 42,000), it is difficult to know which x-axis values are most likely to be representative, because the confidence levels overlap and their distributions are different (the lengths of the confidence interval bars are unequal). One of the solutions proposed for this problem is to allow users to indicate the y-axis value of interest (e.g. 42,000) and then draw a horizontal line and color bars based on this value. So bars might be colored red if they are definitely above this value (given the confidence interval), blue if they are definitely below this value, or white if they contain this value. Even more nuanced- bars can change colors based on a gradient from red to blue, with white included only when the indicated y-axis value is exactly equal to the estimated parameter value from a given sample.


I've chosen to add interactivity to the above with a gradient response, which allows the user to click within the plot in order to set a y-axis value of interest; the bar colors change along a gradient from red to blue with respect to what value the user has selected.

Indicated y-axis value was transformed into a ratio given the error bar (estimated standard error) max and min values ((y - low)/ (high- low)); ratio values were then binned across 10 equal intervals ranging from .09 to 1. Therefore, bar color changes are reflective of the mapping between these intervals and a generated 10 element color gradient (r,g,b) list, with white existing only when the ratio = 0.5 (i.e., indicated y-axis value is exactly equal to estimated parameter value for given sample).
