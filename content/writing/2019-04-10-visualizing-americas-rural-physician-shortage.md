+++
title = "Visualizing America's rural physician shortage"
date = "2019-04-10"
aliases = [ "/rural-docs" ]
recommended = "false"
styles = [ "css/full-width-media.scss" ]
+++

_Note: This is adapted from an essay I wrote as a research assistant during graduate school. You can see the [original essay here](https://dfsnow.github.io/ama_viz/exploratory_plots.html)._

<div style="max-width:600px;display:flex;margin:-3rem auto;">
    {{< picture-embed src="/2019-04-10-colorbar.png" alt="Post color palette" width="1696" height="44">}}
</div>

Rural America is facing a massive and growing shortage of physicians. For the past few decades, doctors have flocked to cities seeking better career opportunities, higher pay, and urban amenities. As a result, only 10% of physicians now live in rural areas, compared to 20% of the overall U.S. population. This maldistribution has potentially disastrous consequences: studies have shown that having physical access to a doctor is an important determinant of health. For many rural Americans, getting this access requires a long drive and a potentially longer wait, resulting in potential health consequences such as a higher likelihood of infant mortality, obesity, and disability. The shortage and its effects are likely to get worse in the coming decades, as an increasing percentage of physicians choose to practice in urban areas.

In response to this crisis, policymakers have implemented two primary measures designed to stem the flow of physicians moving to urban areas. First, the Department of Health and Human Services and others have created wage incentives for doctors practicing in shortage areas. These incentives are designed to attract new doctors to rural areas by offering them a slight wage premium, and to keep rural doctors rural by offsetting their opportunity costs. Second, many medical schools have opened rural branch campuses or programs, ostensibly designed to accustom students to rural life and erode their preference for urban areas.

The assumption of these policies is that doctors live in urban areas simply because they prefer higher density and urban amenities. Unfortunately, this assumption is incomplete and misinterprets the nature and causes of the rural doctor shortage. The rural doctor shortage is not a result of rurality per se, but rather of the urban/rural education and class divide. In short, doctors have an overriding preference for urban areas because urban areas, like doctors, tend to be richer and more highly educated than rural areas. Current policies aimed at changing this preference have been unsuccessful because class is largely an immutable characteristic. Paying doctors more in rural areas will not override their desire to be around other doctors and highly educated people. Instead, policymakers concerned about the rural doctor shortage should focus on recruiting doctors with pre-developed preferences for rural areas and on finding appropriate doctor substitutes, such as nurse practitioners.

Maintaining current policies will waste millions of dollars and do little to ameliorate the rural doctor shortage or improve rural health. Policymakers should pivot toward a new set of policy solutions based on a more nuanced understanding of the shortage and its causes. To that end, the rest of this document is split into three parts: first, describing where the shortage is and what its causes are; second, discussing why current policies have failed; and third, offering new potential solutions.

## Mapping the U.S. doctor shortage

Effective policy responses begin by correctly identifying the problem they’re trying to solve. Policymakers, health professionals, and academics have spent decades studying the spatial distribution of physicians. As early as the 1960s, academics such as Rimlinger and Steele (1961) lamented the shortage of rural U.S. physicians and its potential impact on rural health. Since then, countless academics have updated the methods used for quantifying the shortage, but their shared description of the shortage as being rural has remained the same (where rural typically means lower population density).

Unfortunately, this definition is incomplete. While it’s generally true that rural areas have fewer doctors, there are also rural areas with a high number of doctors relative to their population. These oversupplied areas aren’t just small anomalies, they often encompass entire regions of the United States. The map below shows the physician-to-population ratio (physicians per 100K people) of each U.S. state. The ratio is grouped into quantiles for easier viewing. Most rural southern states (Mississippi and Arkansas) and plain states (Iowa, Nebraska) do have a low number of doctors relative to their population. However, notably rural regions such as the Pacific Northwest (Washington, Oregon) and the far Northeast (Maine, Vermont) are oversupplied.

This distribution indicates that the rural doctor shortage is not driven entirely by rurality, but rather by a combination of rurality and other factors such as educational attainment level. Research shows that educational attainment explains over 40% of the variation in physician supply, while population density (rurality) explains less than 10%. In other words, the rural doctor shortage may be better characterized as a doctor shortage in less-educated areas. Rural areas do have doctor shortages, but they’re largely caused by rural areas being less-educated, rather than by rurality itself. Thus, policymakers have misidentified the cause of the shortage, attributing it to rurality when the truth is likely more nuanced.

{{< picture-embed src="/2019-04-10-doc-population.png" alt="Rural states have a shortage of doctors relative to their population" width="1728" height="1344">}}

The true nature of the doctor shortage can be seen more clearly at the county level. The map below shows an index of the relative level of primary care accessibility for every county in the United States. This index is calculated using a new technique which minimizes the driving time and cost of congestion for each patient. In other words, it allows patients to make a trade-off between distance and crowdedness, with patients moving farther to avoid extremely crowded providers. This method adds to previous literature on spatial accessibility, which is often measured simply as the patient-to-provider ratio of a given space.

Since the algorithm is applied to the entire U.S., the index number it yields is nationally relative and can be used to compare regional or county-level variation in accessibility. In highly accessible (purple) areas, patients drive only a short distance to their doctor and the doctor’s office is unlikely to be crowded when they arrive. In inaccessible (pink) areas, patients may drive for hours to their doctor, only to find themselves competing for attention with the many other patients that doctor serves.

The results from this new method support the hypothesis that physicians prefer to live in highly educated areas. On the map, this can be seen most clearly in the New England region. Maine, Vermont, and New Hampshire have excellent primary care accessibility despite being relatively rural states. Similarly, states in the upper Midwest such as Minnesota, Wisconsin, and Iowa are highly accessible despite being mostly rural. All of these states contain a large number of highly educated people relative to their population. Conversely, Texas and much of the South have poor accessibility despite being relatively more urban. These areas have lower average educational attainment than the rest of the U.S.

Nonetheless, framing the problem as a rural shortage can still be useful. Certain regions notwithstanding, the U.S. generally has a large overlap between rurality and low educational attainment, and areas with the most severe shortages tend to be both very rural and very undereducated. As such, rurality can serve as a useful heuristic, capturing the educated/undereducated area divide in a way that is more intuitive to most people. However, this characterization becomes a problem when used as a basis for policy, where misidentification of the underlying problem can yield ineffective and costly results.

(For the remainder of the article, “rural” is used as a shorthand for “rural and/or undereducated”.)

{{< picture-embed src="/2019-04-10-pc-access.png" alt="Rural counties have poor access to primary care" width="1728" height="1344">}}

Age is also an important aspect of the rural doctor shortage story. In the past three decades, more and more young doctors have settled in cities, while very few have moved to rural areas. This sorting is likely driven by homophily (the desire to interact with and live among people like yourself) and existing demographic shifts in American society. Put bluntly, young, educated people like to live around other young, educated people, most of whom live in cities. Doctors follow this same trend.

Unfortunately, these young, urban doctors tend to stay put rather than move to rural areas as they get older. As a result, rural doctors tend to be an average of 18 years older than their urban peers. In the plot below, the bulk of the distribution of rural doctors is around 60 years old. Many of these doctors will retire in the next few decades and will not be replaced, severely exacerbating the existing crisis.

{{< picture-embed src="/2019-04-10-doc-age.png" alt="Rural doctors are scarcer and older" width="1728" height="1344">}}

The rise in specialist physicians has also contributed to the rural doctor shortage. As more medical students choose high-paying specialties, the proportion of primary care physicians trained each year has decreased, particularly since 2001. The plot below shows this trend.

Specialists are much more likely to practice in urban areas than primary care physicians. Rural areas rarely produce the demand needed to support a specialist. Even if rural demand was sufficient, most rural hospitals do not have the infrastructure, equipment, or funds necessary to support full-time specialists. As a result, specialists are much more likely to live and practice in urban areas.

{{< picture-embed src="/2019-04-10-pc-v-spec.png" alt="More doctors are becoming specialists" width="1728" height="1344">}}

## Doctor preferences and the current policy response

Policymakers have spent millions of dollars trying to solve the rural doctor shortage. Unfortunately, current policies are misguided and focus on the wrong problem, relying on the assumption that geographic variation in physician supply is driven by rurality itself. These policies have each attempted to change physician preferences for rurality but have ignored physicians’ homophily and preference for educated areas. As a result, these policies have largely failed and the rural doctor shortage persists.

One of the most well-known policies designed to address the rural shortage is increasing rural doctor pay. Health and Human Services (HHS) and other healthcare payers reimburse doctors practicing in shortage areas at a higher rate, typically around 10%. The goal of these payments is to incentivize physicians to move to rural areas by offsetting their input and opportunity costs. However, these payments have not worked as intended.

The plot below shows the median wage of urban and rural doctors over time. Since 2000, the wage gap between urban and rural doctors has expanded dramatically, with rural doctors now making roughly $40K more than their urban counterparts. Yet the rural doctor shortage has only worsened, indicating that such payment policies have mostly subsidized already-rural doctors while inducing few urban doctors to move.

{{< picture-embed src="/2019-04-10-wage.png" alt="Rural doctors make more money than urban doctors" width="1728" height="1152">}}

By ignoring wage incentives, urban doctors display an overriding hidden preference for urban areas. Previous research (Lombardo et al.) suggests this preference is a combination of doctors’ preferences for urban amenities and their preference for being around other highly educated people. This partially explains the maldistribution visible in the previous maps. Places such as New England have a high level of educational attainment and nice urban amenities, they therefore have a large number of doctors. Places like Mississippi have low average educational attainment and few urban amenities, they therefore have fewer doctors.

Doctors have this preference for urban areas regardless of their birthplace. The plot below shows the rurality of where different cohorts of physicians end up attending medical school, doing their residency, and practicing. Each line represents a cohort of physicians born in 1 of 10 core-based statistical area (CBSA) deciles. For example, the pink line represents the most rural-born cohort of doctors, while the purple line represents the most urban-born. Each shaded region represents a different level of rurality.

All of the doctor cohorts, regardless of their birthplace rurality, end up practicing in urban/suburban areas. After being mechanically forced to urban areas for school (almost all medical schools are in cities), doctors never return to the same rurality level as their birthplace. This indicates that doctors’ preferences for urban areas may develop as a result of training in those areas. Based on this assumption, some medical schools have developed rural programs intended to give doctors a taste of rural life. However, there is little evidence to indicate that such programs increase rural practice retention.

{{< picture-embed src="/2019-04-10-cohort.png" alt="Doctors move to urban areas regardless of birthplace" width="1728" height="1344">}}

Medical schools also play a role in determining where a doctor chooses to practice. The plot below shows the average MCAT score of each medical school compared to the rurality of the average graduate’s practice location. Graduates of medical schools with higher average MCAT scores tend to end up practicing in more urban areas.

The reason for this is two-fold. First, better medical schools tend to be located in large cities. Doctors at these schools likely develop preferences for big city amenities as well as business and social networks that make leaving undesirable. Second, graduates of better medical schools are more likely to be matched with their preferred residency programs, i.e. they are unlikely to be forced to attend less competitive rural programs.

{{< picture-embed src="/2019-04-10-med-school.png" alt="Competitive medical schools send their graduates to urban areas" width="1728" height="1344">}}

## How do we fix the rural doctor shortage?

The current state of rural American medicine is bleak. Doctors are overwhelmingly clustered in urban and highly educated areas. The existing cohort of rural doctors is rapidly aging and is unlikely to be replaced. More and more doctors are becoming specialists who can only viably practice in cities. Solving the rural doctor shortage seems like an impossible task.

Previous solutions have focused on increasing the compensation of rural doctors, yet this strategy seems to be ineffective. Doctors have such a strong preference for urban areas that it overrides any incentives created by relatively small rural wage premiums. Given this preference, the high earnings of most physicians, and the marginal utility of money, it would likely take a massive wage premium to begin attracting marginal doctors to rural areas.

Instead, two solutions should be implemented. First, medical schools should recruit more students from rural areas. The sixth plot shows that such students are the most likely to practice in rural areas. These students have pre-existing preferences for rurality, i.e. they are not as prone to developing strong preferences for urban areas because they already prefer rural ones. Additionally, students from rural areas are already invested in and familiar with rural communities. Recruiting more of these students would undoubtedly bolster the number of rural physicians.

Second, states should focus on training and licensing more nurse practitioners (NPs). The plot below shows that nurse practitioners already serve as substitutes in states with relatively few doctors. NPs can perform the same basic tasks as a primary care physicians but are cheaper and easier to train and license. Substituting NPs in rural areas could reduce the impact of the rural physician shortage and improve basic health outcomes for rural Americans.

{{< picture-embed src="/2019-04-10-nps.png" alt="Nurses serve as substitutes in states with few doctors" width="1728" height="1536">}}

The worsening maldistribution of U.S. physicians has potentially devastating health consequences for millions of Americans. States and the medical community should act quickly to implement practical solutions that increase the recruitment of rural medical students and NPs.