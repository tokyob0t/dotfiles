from PotatoWidgets import Poll, Variable
from ...utils.github import (
    get_contribs,
    default_contrib_data,
    get_profile,
    default_profile_data,
)


profile = Poll("24h", get_profile, default_profile_data)

contribs = Poll("24h", get_contribs, default_contrib_data)
