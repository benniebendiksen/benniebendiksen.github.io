## Visualizing Scale Means, Race Distribution, and Performing Exploratory Factor Analyses on Updated 2018-2019 surveys of a Professional Teacher Development Program

## Background
The Jhimmy Basu Foundation for Professional Teacher Development contracted Boston College's _Innovations in Urban Science Education_ (iUSE) to the end of refining and distributing its measures for Democracy in STEM Teaching (DST) along with student affective scales, prior to their second survey iteration commencing in 2018.

Although program survey scales were modified along student, teacher fellow, and teacher non-fellow categories, the present analysis focuses on the student grades 6-12 target population of the program.

Analyses of the 2017-2018 survey scales resulted in a finding suggestive of one generalized factor underlying all DST principles. The Boston College research team at iUSE aimed to refine the surveys to better understand the program’s impact on each of the three DST principles. Refining the survey will foster a nuanced understanding of the DST principles in ways that can inform the design and implementation of the program model. The updated 2018-2019 surveys include scales for each of the three DST principles (Student Voice, Shared and Transformational Authority, and Critical STEM Literacy) as well as various affective dimensions that the program aims to support (e.g., sense of community, emotional engagement, and self-concept).

Factor analyses were performed, and reliability estimates generated, in order to assess the validity and reliability of each version of the student surveys (2017-2018 and 2018-2019); the overarching goal was to assess the refinement of the SciEd survey scales in terms of reliability and latent structure. 

The Sci-Ed Student Pre-survey dataset from the academic year of 2017-2018 was accessed in order to enact a first round of reliability assessment and factor analysis (n = 842).  This survey contained four scales including: DST perception, sense of community, engagement, and confidence. The DST perception scale, a scale of five items (questions) that collectively intended to measure the three DST principles, carried a Cronbach’s Alpha of .768; reliability estimates of .7 and above are considered to be acceptable in the education literature. The three remaining scales (sense of community, engagement, and confidence) carried reliability estimates above this value, with a highest estimate of .883. *However*, the items from any of the four scales correlated moderately to highly with the items of all other scales, with values typically ranging from .51 to .74. _Highly correlated items imply that the scales themselves may be inter-correlated to a high degree. A high degree of correlation between items amongst scales is suggestive that a subsequent factor analysis may not be appropriate_. With this piece of evidence in mind, we proceeded to enact a factor analysis by first checking the adequacy of the data. It is important to note that, of the two important adequacy tests underlying the factor analysis model, the Kaiser-Meyer-Olkin (KMO) test resulted in an unacceptable value. This statistic is a measure of the proportion of variance among variables that might be common variance. The lower the proportion, the more suited one’s data is to factor analysis. Our KMO finding suggests a problematically high amount of covariance between our survey scales. This statistic corroborated our previous finding implying high inter-correlations between scales. Using an established method of estimation known as principal axis factoring, an exploratory factor analysis was performed on the data set in order to gleam the number of constructs underlied or represented by scale items. 

Ideally, we would have liked to see one such latent trait (or factor) as underlying each of the four survey scales, with potentially three factors underlying the DST scale (one per principle). Though we initially extracted two to three factors, they correlated so strongly as to be suggestive of representing a single underlying factor. Not surprisingly, we settled on one hypothetical factor from our data set of four scales. We not only caution as to the validity (and interpretability) of the single factor extracted but argue that such inter-correlated items stemmed from a resultant _restricted range across all responses_. This “ceiling effect”, characterized by a disproportionate majority of responses tending towards the upper limit of response options, is indicative of overly “easy” items and further warranted our motivation behind the modification of survey scales.

## Scale Modifications
These results prompted us to look for peer-reviewed scales that aligned with each of the DST principles as well as the affective dimensions of interest (e.g., sense of community, emotional engagement, self-concept). After reviewing the literature, we identified complementary scales to include in the student and teacher versions of the surveys. These scales were then shared with the Basus and the SciEd Leadership teams in Boston and New York for feedback and revisions. This process resulted in the development of three survey versions: Grades 3-5 Student Survey, Grades 6-12 Student Survey, and Teacher Survey (for both fellows and non-fellows). These surveys were implemented across the schools of the SciEd fellows in New York and the Boston area in the fall of 2018 in both English and Spanish versions.

## 2018-2019 Sci-Ed Finalized Student (grades 6-12) Survey
The 2018-2019 Student Survey (grades 6-12), which is central to this analysis, included seven survey scales: (1) Shared & Transformational Authority, (2) Student-Student Voice, (3) Student-Teacher Voice, (4) Critical STEM Literacy, (5) Sense of Community, (6) Emotional Engagement, and (7) Math or Science Self Concept. After both pre and post surveys were administered during the academic year, we followed up with the present summary and factor analyses project in R. Unlike the 2017 dataset, it was the case that both adequacy tests yielded positive results encouraging the subsequent use of a factor analysis for the 2018-2019 dataset. Drawing from various heuristics designed to guide the factor extraction process we settled upon eight dominant factors both times. Both analyses suggested that one factor loaded strongly for each of the following scales: Emotional Engagement, Sense of Community, Critical STEM Literacy, Student-Teacher Voice, and Student-Student Voice. Otherwise, we note that Math/Science Self-Concept scale (5 items) loaded across two factors. Furthermore, we note that the Shared & Transformational Authority scale failed to load strongly on any factor as well. We will work on revisiting the literature and refining these scales in preparation for administering a third round of surveys during the 2019-2020 academic year.

## Conclusion
In sum, we consider this a significant improvement in aligning the latent structures of all but two of our seven scales to a single latent trait per scale, the exceptions being Math/Science Self-Concept and Shared & Transformational Authority, notwithstanding a single item from our Community Connectedness scale. This analysis provides strong evidence of a refined survey instrument where scale items more closely point at the same concept. We conclude that the successive factor analysis suggested much greater congruency between scales and the theorized unobservable traits they represent, and that they did so without loss in reliability. Looking ahead, we will focus on refining the survey scales of Shared and Transformational Authority as well as Math/Science Self-Concept. We suggest a more strongly worded scale for the former and a previously validated replacement scale for the latter, with subsequent tailoring of the items in order to best fit the context of Sci-Ed’s mission.
