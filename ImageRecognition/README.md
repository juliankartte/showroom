# Goal
The goal of this project was to classify images by using a convolutional neural network (CNN) into one of the classes *rock*, *paper*, *scissors* and *rest*, where the first three labels represent one of the hand guestures known from the game rock, paper, scissors and *rest* representing arbitrary images that do not belong to one of the other three classes. 

# Dataset
As a base dataset around 700 images for the three hand guestures were taken from [Julien de la Bruère-Terreault](https://www.kaggle.com/datasets/drgfreeman/rockpaperscissors). In addition, around 500  images for each hand guesture and 660 images for the class rest were recorded and added to the dataset. In total, 1265 images for *paper*, 660 images for *rest*, 1249 images for *rock* and 1272 images for *scissors* were used. 

# Preprocessing
It should be noted that the dataset is not balanced and that the number of images is relatively low. Thus, preprocessing was used for the hand guestures by rotating the images by 180 degrees. To balance the rest class the corresponding images were rotated and mirrored horizontally. After the preprocessing the dataset consists of 2500 images for each class.  
The program displayed in the uploaded file was run on this balanced dataset. In case you are interested in this dataset feel free to contact me on [linkedin](https://de.linkedin.com/in/julian-kartte-aa64a9237?trk=people-guest_people_search-card).
