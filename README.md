# Odd One Out

This is a digital version of the out one out task from Henry (2001).

> Henry, L. A. (2001). How does the severity of a learning disability affect working memory performance? <i>Memory</i>, <i>9</i>(4–6), 233–247. https://doi.org/10.1080/09658210042000085

This project is coded in JavaScript using the JsPsych framework created by Josh de Leeuw <https://www.jspsych.org/7.2/>

This project and the supporting documentation were created by Ron Pomper <https://rpomper.github.io>

## Overview

In this task, participants are shown images of three similar-looking figures in a row: two of the figures are identical and the third differs slightly from the other two. The participant is tasked with clicking on the figure that is different from the others (__odd one out trial__). The figures are then replaced with images of three rectangular boxes in a row. The participant is then tasked with recalling and pointing to the position of the odd one out figure (__position recall trial__).

The task begins with two practice trials: one with a 1-item length (i.e., identify one odd one out before recalling its position) and one with a 2-item length (i.e., identifying two odd ones out before recalling their positions).

The task then consists of 6 blocks of test trials with each block increasing the number of items to recall (starting with 1-item length, ending with 6-item length). Each block contains four odd one out sequences and four position recall trials. Responses on position recall trials are scored correct only if the participant correctly identifies the positions for every odd one out figure in the sequence (e.g., all 6 positions in the 6th block). Note: when participants incorrectly identify which figure was the odd one out, this position is used as the target position on the position recall trial.

Administration of the task will automatically stop (i.e., before the end of the 6th block) when the participant answers incorrectly on two or more of the four position recall trials within a block.

The participant's visuospatial working memory is then quantified as the total number of position recall trials that were correct (with a maximum score of 24).

## How to administer

Participants complete this task online via a web browser. The code will work using both a computer (where participants click on the images) and via a tablet (where participants tap on the images). In principle, the code should also work on a phone, but I have not tested the dimensions (it may be difficult to see all of the images on a small screen).

When entering the URL for this task, there are two variables that can be embedded within the link:

* __sub__: this will be saved with the REDCap data as subject_num
* __api__: this will be used within the script to save the participant's responses to a REDCap project

To do this, append the following to the end of the URL:

  /?sub=1&api=007


This project is hosted publicly via GitHub, so you can use the URL for this project:

  <https://rpomper.github.io/OOO/?sub=Ron&api=>


Alternatively, if you would like to make any adjustments to the code, you can Clone the GitHub repository and host it yourself (more on that below).


## How to set up the REDCap project

1. Create an empty project in REDCap. Click on the _Designer_ tab. Then click the pencil next to the _Instrument Name_ to modify the instrument:

    <img src="/stimuli/images/how-to-1.png" alt="" title="step 1"/>

    ![Step 1](/stimuli/images/how-to-1.png)

2. Within the instrument create the following fields with the exact variable names (the script will be looking for these when saving the data to REDCap):

  ![Step 2](/stimuli/images/how-to-2.png)

3. Next you'll need to enable the API token feature, which is not on by default. To do this, click on the _User Rights_ tab. Then click on your user name:

  ![Step 3](/stimuli/images/how-to-3.png)

4. Scroll down and click on the two boxes next to API:

  ![Step 4](/stimuli/images/how-to-4.png)

5. Refresh your webpage and click on the _API_ tab (which will now be visible!) and click the _Request API token_ button:

  ![Step 5](/stimuli/images/how-to-5.png)

6. Once the administer approves this, copy and paste this number somewhere that is accessible. This is the information you will need to embed in the URL after "api=" (see above)


## How to clone the GitHub repository
