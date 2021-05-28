+++
title = "Lessons learned in local government"
date = "2021-05-24"
recommended = "true"
+++

I've been working as a data scientist in local government for around a year and a half now. Not long, but long enough to learn some things and update a few of my opinions.

None of these lessons are specific to my organization or role. Friends in other agencies confirm they generalize well to most positions at the intersection of data and local government.

I'm sharing these lessons with two goals:

1. To help myself remember them and to keep a running log of what I've learned.
2. To (hopefully) help other people avoid the same painful mistakes.

## Things I've learned

- **Local government is incredibly risk averse and therefore difficult to change.**
   - On the elected side, there's an information problem. Voters are more likely to notice (and thus punish) bad outcomes, while good outcomes are often overlooked by both media and voters. This reduces the incentive to change the status quo (high risk, low potential reward) and turns policy into a communications problem.
   - On the career side, there's an incentives problem. Most career local government employees value stability. They may not prefer the status quo, but they know that shaking things up is riskier than doing nothing. They're also unlikely to be rewarded for status quo improvements or additional effort (due to pay schedules and a slow promotion process).

- **Big technology changes in local government usually happen through contracting.** This is because:
   1. Elected and appointed employees use contracting as a way to mitigate personal risk.
   2. Contracting helps ensure the start/survival/continuity of status-quo-changing projects.
   3. Most local governments lack the technical capacity/talent to do major tech overhauls in-house.

- **Small things take a *long* time if they haven't been done before.** New tasks require new processes. New processes require delegation of responsibility, updated budgets, and lots of communication. All of this is very slow. It once took me around 7 months to get a VM approved and spun up.

- **Attention causes change.** Most local government bodies (besides cities and police departments) receive little to no public attention. As a result, they tend to be fairly responsive when they *do* receive attention, positive (helping an organization improve, providing feedback) or negative (vocal criticism, the threat of media scrutiny).

- **The boring stuff often matters the most.** Most people aren't affected by the sexy, hot-button social or cultural issues covered by national media. Conversely, local things like taxes, zoning, housing, and garbage pickup have a profound impact on people's everyday lives.

- **Local government data is worse than you think.** The systems for storing most local government data are antiquated, messy, and often have decades worth of various kludges. Government's main advantage when collecting data is the ability to mandate compliance by law (usually from businesses).

- **Job satisfaction comes from impact. Impact comes from leverage.** Leverage is built through rapport with others, ownership of projects/processes relevant to the organization's mission, and trust that you can implement/get things done.

## Things I've changed my mind about:

- **People skills are just as important as technical skills.** I wish I could go back and slap myself in the face with this knowledge. Unlike at a cool startup or some FAANG company, you *will not* be recognized in local government for your PhD-level knowledge of the latest ML techniques.
   
   Day-to-day stuff in local government gets done through collaboration and clear communication with lots of different stakeholders. That means the understandability of your work is more important than the purity of your code. The success of a project is dependent on your leverage and how well you explain the project's utility to people above you. 
   
   If you really want to do technical work in government without dealing with people, find a manager who understands the value of your technical skills and will boost/cover/hype for you. 

- **Legacy systems aren't necessarily bad.** They can be crazy fast and also very good at the specific thing they were designed for. The issues start when new requirements pop up and you need to shoehorn some horrible new process into your 1980s mainframe.

- **Domain knowledge is vital, especially for data people.** Career employees may not be able to build a cutting-edge ML model, but they probably have more knowledge about the data and its constraints than you ever will. Go talk to them, in-person if possible. If you don't, you might spend a year thinking that `APTS = 5` means five apartments, rather than six apartments (5 is the categorical encoding for the numeric value 6).

- **Management skills are incredibly valuable.** I entered government thinking of managers as less valuable than technical employees. I was wrong. So much local government work is about people, processes, and dealing with stakeholders; a manager can really make (or break) a small organization or department. Unfortunately, one of local government's biggest problems is a lack of good managers (on all levels). 

- **Old technology is good actually.** By "old" here I mean tech that's 5-10 years old i.e. not brand new. Such technology is usually super stable, well-performing, and well-documented. Chasing the newest stack is for startup folks. 

- **The simplest possible solution is the best solution.** Someone after you will have to maintain your code. Moreover, if you're producing public-facing work, it should be simple for the sake of transparency. Remove complexity (and technologies) whenever possible.

- **Decision makers (rightly) do not care about the technical details.** This was a tough lesson. Decision-makers care about options, their implications, and their potential risks. They do not care about how a boosted tree model works.

## Opinions that haven't changed:

- **Avoid vendor lock-in, prefer open-source.** Local governments tend to prefer SaaS tools. They offload support costs to a third-party and (arguably) require less technical, less independent users. However, with the right team, open-source can be more transparent, cheaper, and can help build connections to the wider developer community. On a related note, open-source GIS tools > ESRI.

- **The potential impact of a motivated, smart person is extremely high.** Local government is bereft of competent data people despite being awash in data and data-related problems. A sufficiently motivated person can accomplish *a lot* in local government even with an average data science skill set. The first (and hardest) step is to find a team with the leverage and mandate to create change.
