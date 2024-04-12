from datetime import datetime

import requests
from PotatoWidgets import Variable, Widget

from .config import GITHUB

TOKEN = GITHUB["TOKEN"]
USERNAME = GITHUB["USERNAME"]

default_contrib_data = {
    "totalContributions": 0,
    "weeks": [
        {
            "contributionDays": [
                {"contributionCount": 0, "date": "2000-00-00"} for _ in range(0, 7)
            ]
        }
        for _ in range(0, 53)
    ],
}

default_profile_data = {
    "username": USERNAME,
    "name": USERNAME,
    "followers": 0,
    "following": 0,
    "created_at": 0,
    "total_stars": 0,
}


def get_contribs():
    url = "https://api.github.com/graphql"

    variables = {"userName": USERNAME}

    headers = {
        "Authorization": f"Bearer {TOKEN}",
    }

    query = """
	query($userName:String!) { 
		user(login: $userName){
			contributionsCollection {
				contributionCalendar {
					totalContributions
					weeks {
						contributionDays {
							contributionCount
							date
						}
					}
				}
			}
		}
	}
	"""

    response = requests.post(
        url, headers=headers, json={"query": query, "variables": variables}
    )
    if response.status_code != 200:
        return
    response = response.json()["data"]["user"]["contributionsCollection"][
        "contributionCalendar"
    ]

    total = response["totalContributions"]
    weeks = response["weeks"]
    return default_contrib_data

    # return {"totalContributions": total, "all_stuff": total}


def get_profile():
    url = f"https://api.github.com/users/{USERNAME}"
    repos_url = f"https://api.github.com/users/{USERNAME}/repos"

    try:
        data = requests.get(url)
        repos_data = requests.get(repos_url)

        if data.status_code != 200 or repos_data.status_code != 200:
            return default_profile_data
    except:
        return default_profile_data

    data = data.json()
    repos_data = repos_data.json()

    total_stars = sum(repo["stargazers_count"] for repo in repos_data)

    return {
        "username": data["login"],
        "name": data["name"] or data["login"],
        "followers": data["followers"],
        "following": data["following"],
        "created_at": data["created_at"],
        "total_stars": total_stars,
    }
