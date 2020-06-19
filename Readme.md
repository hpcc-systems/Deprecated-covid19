![Intro](/docs/images/readme/intro.png)

# HPCC Systems Covid 19 Tracker

An open data lake solution for research and collaboration to track and report the progress of Covid 19 virus.

This system was built around a Production Data Lake Architecture (see [Data Lake Whitepaper](https://hpccsystems.com/End_to_End_Data_Lake_Management_Whitepaper)) allowing incremental value extraction, easy incorporation of new data sources, and rapid transition to production.

The goal of the project is to provide unique insights into the state and progress of the pandemic for each reporting location.  This system is for the benefit of researchers, health workers, government agencies, and the general public.  Data is presented in a balanced, digestable form, allowing individuals sufficient information and context to make reasonable decisions, rather than relying on news sources that are often sensationalized or politicised.  It includes a "Hot Spots" module that identifies locations (e.g. Countries, States, Regions, Counties) that are experiencing the worst outbreaks at the current time.  This could potentially aid in triage for various health organizations around the world.

# Background

The COVID-19 crisis moves at a very quick pace.  Changes in social behavior can result in rapid changes to the overall picture.  Monthly analysis would be obsolete by the time the analysis was available.  Daily results are too noisy to be useful for decision making.  We therefore chose weekly analysis as the optimal time frame to understand the situation.  While we present the data on a daily, weekly, and cumulative basis, the primary analysis of the current situation is based on a sliding 7 day window.

We start by trying to understand the spread rate of the virus in a particular population (i.e. location).  Epidemiology uses an effective reproductive growth rate known as _"R"_ to represent the speed of spread.  R defines the number of people a single individual is likely to infect over the course of their infection.  Infections spread exponentially, and R represents the base of the exponent.  An R value of 1.0 would represent a steady state in the number of active infections – each person would infect one other person, so the overall infection rate (number of active infections) would not change.  An R value greater than 1 means that the infection is growing among the population, while an R value below 1 indicates that the infection is subsiding.  With an R of 2.0, an infection would double the number of new cases every ten days or so.  The higher the R value, the faster the doubling rate.  Likewise, an R of .5 would halve the number of new cases every ten days.

We can’t observe R in practice, so we try to approximate it from the number of confirmed cases and the number of deaths due to the virus.  The approximation based on confirmed cases we designate _Case Growth_ (cR).  The approximation based on deaths, we designate as _Mortality Growth_ (mR).  These numbers do not perfectly reflect R, but they are the best proxies available.  cR is biased by the changing availability and policies around testing.  If we had randomized testing, we could better approximate R.  If we only test hospitalized patients, then cR will understate R.  If the testing policy is shifting, then cR may either under or overstate R. mR, on the other hand, is a more objective indicator.  It is less affected by policy, but may be biased by changes in medical care, such as improved treatments over time.  mR also lags cR, so it is not as timely an indicator.  By combining mR and cR, we get a better overall approximation of R.

By approximating R, we can quickly assess the situation in a given location.  As an infection spreads within a location, one of two situations typically arises:
* The infected people will be quarantined and their contacts traced and also quarantined.  If this is successful, the infection is said to be Contained, and R will quickly decrease.
* Containment fails, either due to late detection, failure to trace all contacts, or insufficient resources to enact the containment.  In this case, the infection will spread uncontrolled until social behavior (e.g. social distancing) causes it to be controlled.  This process is known as Mitigation.

By following changes in R, we can quickly see how the infection is responding to Containment or Mitigation.  In the early Emergent stages of the infection, we commonly see R values greater than 3, which indicate a very fast exponential growth.  As the infection is contained, or social distancing is deployed, R quickly falls to between 1 and 2, which can still be very rapid growth.  At R = 2, the cases will double every 10 days.  As the case growth increases, people tend to become more and more careful until R falls below 1.  At this point the active infections stop increasing and gradually begin to decrease.   We expect that this will tend to make people less careful, and we expect to see oscillation above and below 1.  If social distancing can be maintained for a longer period, then the infection can be ultimately re-contained.

# Causal Model

We use an evolving model of the cause and effect relationships between observed and unobserved (latent) variables to inform the definition and interpretation of metrics.  This model lets us visualize the ways in which measurements are confounded by hidden variables, and possible ways to de-confound the meanings.

![Causal Model](/docs/images/readme/CausalModel.png)

# Infection State

The levels of cR and mR along with some other data, allow us to classify an outbreak according to its stage:
* _Spreading_ -- Number of active infections is rapidly increasing (R >= 1.5) and the scale of the infection is probably beyond containment.
* _Emerging_ -- Number of active infections is rapidly increasing (R >= 1.5), but is small enough to potentially contain.
* _Stabilizing_ -- Infection slowly growing (1.1 <= R < 1.5).
* _Stabilized_ -- Number of active infections is approximately stable (.9 <= R < 1.1).
* _Recovering_ -- Number of  active infections is shrinking (R < .9), but is still beyond containment.
* _Recovered_ -- Number of active infections is shrinking or stable, and scale is containable.

These define the potential values of the  _Infection State_ at a given location.

# Epidemiological Model

 The system embeds a classical epidemiological model known as SIR (see [Wikipedia Article](https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology)).  The SIR model predicts the changes in Susceptibility, Infection, and Recovery using a set of differential equations.  This allows us to estimate quantities such as Active Infections, Recovered Infections, Percent Immunity, Time-to-peak, Deaths-at-peak, and Time-to-recovery.
 
 In practice, the SIR model gives us a good estimate of Active versus Recovered infections, but predictive power is limited due to rapidly changing social and societal behaviors.  In animal epidemiology, the growth rate (R) is typically identical to the Basic Reproductive Rate (i.e. R0) of the virus.  In human society, there are both innate and orchestrated responses to a pandemic that cause R to rapidly diverge from R0.  Changes in behavior such as quarantines, social distancing, and enhanced hygiene can quickly dampen the growth rate.  Returning to normal behavior can rapidly increase the rate.  Therefore any predictions of growth must model the expected changes in human behavior, which is beyond the scope of the current system.
 
# Other metrics

Given a reasonable estimate of R, cR, and mR, we can begin to infer some other metrics that further illuminate the nature of the infection.
Metrics are developed to provide insight into the dynamic state of the infection within a location.  They may illustrate temporal changes as well as contemporaneous relationships within the data.


The _Case Fatality Rate_ (CFR) is the likelihood that someone who tests positive for the virus will die.  This is useful for comparing medical conditions between locations with a similar testing and reporting protocol and testing constraints.  It is somewhat confounded by changes in testing availabilty.  It almost always overstates the fatality of the infection and should not be confused with the _Infection Fatality Rate_.

The _Infection Fatality Rate_ (IFR) is the likelihood that someone who catches the infection will die.  This is a very elusive number due to the difficulty in estimating the actual number of infections in a population.  This can be retroactively assessed via antibody testing, or approximated through calibrated adjustments.

_Cases Per 100K_ combines location population data with the COVID-19 reported data to look at the proportion of a population that has tested positive for the virus.  Ths is useful to normalize the infection rates across populations of different sizes.  We use "per 100,000" as our scaling factor since it is an easier number to work with than the tiny numbers one would get using a per capita calculation.

_Deaths Per 100K_ looks at the death rate per 100,000 population at a given location.

_Immune Percent_ identifies the percentage of the population which has recovered from the infection and are presumed to be immune.  As a larger proportion of the population becomes immune, the spread of the virus is dampened until at some level so called "herd immunity" is attained.  At that point, it is difficult for the infection to continue as there are too few non-immune targets.

The _Heat Index_ is a composite metric that combines a number of relevant metrics to indicate the relative level of attention a given location needs.  This index is calibrated such that values greater than 1 indicate that attention is likely needed. 

Indicators are a type of metric that can have negative or positive values.  We define our indicators such that negative values imply negative outcomes.  Indicators highlight both the direction and relative magnitude of change.

The _Social Distance Indicator_ (SDI), based on change in Case Rate (cR), provides insight into the level of social distancing being practiced by a population.  All other things being equal, a reduction in R is caused by an increase in social distancing, while an increasing R is indicative of reduced social distancing.  This can be somewhat confounded by changes in testing policy and availability, but in practice is a good short term indicator.

The _Medical Indicator_ (MDI) is based on changes in the ratio of Case Rate (cR) to Mortality Rate (mR).  If all else is held constant, this ratio would settle at a consistent value, as the rate of increase in deaths would be proportional to the rate of growth in cases.  Therefore, a decrease in the ratio signals that something has changed for the worse.  In practice, this can be caused by a number of factors: 1) Testing is not growing as fast as the infection, 2) Medical Care is worsening or 3) Rapid changes in R combined with the time lag of deaths can cause skew between the two.  If we adjust for the time lag, then either of the first two causes can be considered medical care issues.  Thus decreases in this ratio will result in a negative _Medical Indicator_.

The _Short Term Indicator_ (STI) is a predictive indicator that attemtps to determine if the infection is likely to get worse (negative values) or get better within a few days.

The _Early Warning Indicataor_ (EWI) predicts major shifts (inflection points) in the momentum of the infection.  It is meaningful when an infection is moving from a neutral or recovering state to a spreading state.  It is also meaningful when an infection is transitioning from growth to stability.

# Surge detection

The system tracks ebbs and flows in the infection rate to show multiple "surges" or "waves" of infection.  We define a surge as a transition from a shrinking state to a growing state.  We track the start dates, peaks, and durations of each surge.  Knowing the surge number and start date helps in understanding the oscillations that a location goes through over the life of the infection.

# Commentary

A unique aspect of this system is the ability to produce a daily English commentary reflecting the state of each location.  The commentary combines metrics-based inferences with enough background information to help the reader understand the implications.   For example, here is a commentary describing the state of the World-wide infection for June 18, 2020.

_"The World has worsened to a Stabilizing state from a previous state of Stabilized. The infection is slowly increasing (R = 1.18). At this growth rate, new infections and deaths will double every 42 days. This is the 2nd surge in infections, which started on the week of May 28, 2020. With 989,711 new cases and 32,758 new deaths, this is the worst week yet for cases and deaths during this surge. It appears that the level of social distancing is decreasing, which may result in higher levels of infection growth. The Case Fatality Rate (CFR) is estimated as 6.4%. The Short-Term Indicator suggests that the infection is likely to worsen over the course of the next few days."_

# User Interface

The system provides a friendly web-based interface for viewing COVID-19 data and metrics.  World, Country, and Regional maps are color coded to represent any of various selectable attributes of the infection at those locations.  Clicking on any given location brings up a set of pages that provides details about that location -- from raw statistics to charts to advanced metrics and commentary.

The user interface provides several ways to navigate:
* _Map View_ shows aspects of the infection through color codings on a map.  The map can be color coded by a number of attributes including Infection State, New Cases, New Deaths, Cases per 100K, Deaths per 100K, Total Cases and Total Deaths.
* _Hotspots View_ orders the locations by _Heat Index_,  showing a triage list of locations and a description of their state.  All details can be by clicking on any of the Hotspot locations.
* _Comparison View_ allows simultaneous viewing of statistics from multiple selected locations of interest.
