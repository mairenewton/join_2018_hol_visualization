# Census Data Explorer

## Introduction

This LookML Project is a transformation of data downloaded from the Census Bureau's DataFerrett. DataFerrett downloads include both a data file and a codebook file. This project uses Python scripts stored [here](https://github.com/looker/census_looker) to merge the data files for upload to BigQuery and to generate LookML for interpreting that data.

Because the LookML is machine-generated, we isolate the Python-generated LookML in its own files and don't edit them by hand. This ensures that if we need to regenerate the LookML with the Python scripts, we can overwrite the entire files. We keep all the human-written LookML in its own files that extend the machine-written LookML and make all edits there.

The machine-written LookML is contained in the following files:
- `cps_voter_supp_base`
- `cps_voter_supp_filters`
- `cps_voter_supp_measure`
- `cps_voter_supp_base_wo_cohort`

The human-written LookML is contained in:
- `cps_clean`
- `cps_with_groups`
- `total_hh_members`

## Editing existing dimensions

Sometimes you'll want to edit dimensions that already exist in the model. For example, you might want to make the label of the dimension more easily understood or change the definition of its tiers. To edit an existing dimension, simply extend the dimension by finding its name in `cps_voter_supp_base`, and add the dimension to both `cps_clean` and `cps_with_groups`. Then make whatever changes you want in those views, so that they extend and revise the definition of the field.

So, for example, if you wanted to change the tiers for the tiered age dimension, you would navigate to the dimension in `cps_voter_supp_base` and find that it's called `prtage`. You would not edit that definition directly in `cps_voter_supp_base`, but rather, would navigate to `cps_clean` and add the following:

    - dimension: prtage
      tiers: [0,10,20,30,40,50,60,70,80,90]

That would redefine the tiers for the CPS Household Explorer. Assuming you also want to redefine the tiered age dimension in the CPS Group Explorer, you would add the same two lines to `cps_with_groups`.

## Adding new dimensions

If you want to add a new dimension to the model--let's say you want a dimension for "Over 40"--you would define that directly in `cps_clean` and `cps_with_groups`.

You'll need to come up with a dimension name that hasn't been used before--we'll use `over_40`. So you would add the following to `cps_clean`:

    - dimension: over_40
      type: yesno
      label: Over 40 years old
      view_label: Demographic Variables
      sql: ${prtage} > 40

If you also want that new dimension to be available in the CPS Group Explorer, you'll need to add the same defition to `cps_with_groups`. However, because of some weirdness about the way filter-only fields treat `yesno` dimensions, it's better to make the dimensions in `cps_with_groups` of type `string`.  So you'd do:

    - dimension: over_40
      type: string
      label: Over 40 years old
      view_label: Cohort Demographic Variables
      sql: CASE WHEN ${prtage} > 40 THEN 'Over 40' ELSE 'Not Over 40' END

(Notice that the view label in `cps_with_groups` must be prepended with "Cohort".)

After you've defined the dimension in `cps_with_groups`, assuming you also want this dimension to be available as a filter on the group (and not just the cohort), you'll need to take some additional steps.

First, directly below the new dimension definition, define a filter-only field with the same name as the dimension, but prepended with the word `select_` and the view_label prepended with "Group" instead of "Cohort". You'll also want to add a  `suggest_dimension` that points at the dimension you just created. So in this case, that'd look like this:

    - filter: select_over_40
      label: Over 40 years old
      view_label: Group Demographic Variables
      suggest_dimension: over_40

Now that the filter-only field exists for the group, you'll need to add it to the measure definitions that implement the groups. Those measures are `group_population` and `group_households`. To operationalize the filter-only field, scroll to the bottom of each of those two definitions and add a conditional filter referring to your new definition and filter.

In this case, that'd look like this:

    AND {% condition select_over_40 %} ${over_40} {%endcondition%}

Remember to add that line to both the `group_population` and `group_households`.

Once you've completed your work, go into the Explores and confirm that your new dimensions/filters work the way you intend.  An easy way to check that the filter-only fields are working correctly is to add a filter to the **dimension** and then get the value of the `People in Cohort` measure. Then remove that filter, and add the same filter to the filter-only version and select `People in Group`. If you've implemented everything correctly, the value you get for `People in Group` should match the one you got for `People in Cohort`.
