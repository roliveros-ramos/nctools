# version 0.2.0

**round 1**

Thanks,

If there are references describing the methods in your package, please
add these in the description field of your DESCRIPTION file in the form
authors (year) <doi:...>
authors (year, ISBN:...)
or if those are not available: <https:...>
with no space after 'doi:', 'https:' and angle brackets for
auto-linking. (If you want to add a title as well please put it in
quotes: "Title")
For more details:
<https://contributor.r-project.org/cran-cookbook/description_issues.html#references>

\dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
("# Not run:") as a warning for the user. Does not seem necessary.
Please replace \dontrun with \donttest.
Please unwrap the examples if they are executable in < 5 sec, or create
additionally small toy examples to allow automatic testing. (You could
also replace \dontrun{} with \donttest, if it takes longer than 5 sec to
be executed, but it would be preferable to have automatic checks for
functions. Otherwise, you can also write some tests.)
For more details:
<https://contributor.r-project.org/cran-cookbook/general_issues.html#structuring-of-examples>


Please fix and resubmit.

Best,
Benjamin Altmann
