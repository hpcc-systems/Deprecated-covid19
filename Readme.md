![Intro](/docs/images/readme/intro.png)

# HPCC Systems Covid 19 Tracker

An open data lake solution for research and collaboration to track and report the progress of Covid 19 virus. 

The COVID-19 crisis moves at a very quick pace.  Changes in social behavior can result in rapid changes to the overall picture.  Monthly analysis would be obsolete by the time the analysis was available.  We therefore chose weekly analysis as the optimal time frame to understand the situation.

We start by trying to understand the spread rate of the virus in a particular population (i.e. location).  Epidemiology uses a growth rate R to represent the speed of spread.  R defines the number of people a single individual is likely to infect over the course of their infection.  An R value of 1.0 would represent a steady state in the number of active infections – each person would infect one other person, so the over infection rate would not change.  An R value greater than 1 means that the infection is growing among the population, while an R value below 1 indicates that the infection is subsiding.
Now we can’t observe R in practice, so we try to approximate it from the number of confirmed cases and the number of deaths due to the virus.  The approximation based on confirmed cases we designate cR (Case growth).  The approximation based on deaths, we designate as mR (Mortality Growth).  These numbers do not perfectly reflect R, but they are the best proxies available.  cR is biased by the changing availability and policies around testing.  If we had randomized testing, we could better approximate R.  If we only test hospitalized patients, then cR will understate R.  If the testing policy is shifting, then cR may either under or overstate R. mR, on the other hand, is a more objective indicator.  It is less affected by policy, but may be biased by changes in medical care, such as improved treatments over time.  mR also lags cR, so it is not as timely an indicator.  By combining mR and cR, we get a better overall approximation of R.

By approximating R, we can quickly assess the situation in a given location.  As an infection spreads within a location, one of two situations typically arises:

The infected people will be quarantined and their contacts traced and also quarantined.  If this is successful, the infection is said to be Contained, and R will quickly decrease.
Containment fails, either due to late detection, failure to trace all contacts, or insufficient resources to enact the containment.  In this case, the infection will spread uncontrolled until social behavior (e.g. social distancing) causes it to be controlled.  This process is known as Mitigation.

By following changes in R, we can quickly see how the infection is responding to Containment or Mitigation.  In the early Emergent stages of the infection, we commonly see R values greater than 5, which indicate a very fast exponential growth.  As social distancing is deployed, R quickly falls to between 1 and 2, which can still be very rapid growth.  At R = 2, the cases will double every 10 days.  As the case growth increases, people tend to become more and more careful until R falls below 1.  At this point the active infections stop increasing and gradually begin to decrease.   We expect that this will tend to make people less careful, and we should see oscillation above and below 1.  If social distancing can be maintained for a longer period, then the infection can be ultimately re-contained.

The levels of cR and mR allow us to classify an outbreak according to its stage:  Emerging, Spreading, Stabilizing, Stabilized, Recovering, or Recovered.  We can also quickly spot locations that are Regressing after having stabilized or recovered.

In order to calculate these metrics, our system embeds an epidemiological model known as SIR.  The SIR model predicts the changes in Susceptibility, Infection, and Recovery as a set of differential equations.  This also allows us to estimate quantities such as Active Infections, Recovered Infections, Percent Immunity, Time-to-peak, Deaths-at-peak, and Time-to-recovery.


