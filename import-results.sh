output=$(command -v brew)
if [ -z $output ]; then
  printf 'Missing brew command. Please install Homebrew first.\n';
fi

echo "️Download zip & unzip them."
mkdir -p tmp
urls=(
  "https://media.fdj.fr/static/csv/loto/loto_201911.zip"
  "https://media.fdj.fr/static/csv/loto/loto_201902.zip"
  "https://media.fdj.fr/static/csv/loto/loto_201703.zip"
)
for url in "${urls[@]}"
do
  printf "Downloading $url:\n"
  wget -O tmp/tmp.zip -N ${url} 2>&1 | grep "not retrieving" 2>&1 > /dev/null || unzip -o tmp/tmp.zip -d tmp
done
rm tmp/tmp.zip

echo "️Parse CSV and generate JSON."
echo "️[1/3]"
vim -u NONE +'1d' +'wq!' tmp/loto_201911.csv # Remove first line.
jq -Rsn '
    [
      inputs
      | . / "\n"
      | (.[] | select(length > 0) | . / ";") as $input
      | {
          "date": $input[2],
          "first_draw": {
            "draw": $input[4:9],
            "chance": $input[9],
            "results": {
              "1": {
                "prize": $input[12],
                "winners_total": $input[11],
              },
              "2": {
                "prize": $input[14],
                "winners_total": $input[13],
              },
              "3": {
                "prize": $input[16],
                "winners_total": $input[15],
              },
              "4": {
                "prize": $input[18],
                "winners_total": $input[17],
              },
              "5": {
                "prize": $input[20],
                "winners_total": $input[19],
              },
              "6": {
                "prize": $input[22],
                "winners_total": $input[21],
              },
              "7": {
                "prize": $input[24],
                "winners_total": $input[23],
              },
              "8": {
                "prize": $input[26],
                "winners_total": $input[25],
              },
              "9": {
                "prize": $input[28],
                "winners_total": $input[27],
              },
            }
          },
          "second_draw": {
            "draw": $input[32:37],
            "results": {
              "1": {
                "prize": $input[40],
                "winners_total": $input[39],
              },
              "2": {
                "prize": $input[42],
                "winners_total": $input[41],
              },
              "3": {
                "prize": $input[44],
                "winners_total": $input[43],
              },
              "4": {
                "prize": $input[46],
                "winners_total": $input[45],
              }
            }
          }
        }
    ]
' < tmp/loto_201911.csv > tmp/loto_1.json

echo "️[2/3]"
vim -u NONE +'1d' +'wq!' tmp/loto_201902.csv # Remove first line.
jq -Rsn '
    [
      inputs
      | . / "\n"
      | (.[] | select(length > 0) | . / ";") as $input
      | {
          "date": $input[2],
          "first_draw": {
            "draw": $input[4:9],
            "chance": $input[9],
            "results": {
              "1": {
                "prize": $input[12],
                "winners_total": $input[11],
              },
              "2": {
                "prize": $input[14],
                "winners_total": $input[13],
              },
              "3": {
                "prize": $input[16],
                "winners_total": $input[15],
              },
              "4": {
                "prize": $input[18],
                "winners_total": $input[17],
              },
              "5": {
                "prize": $input[20],
                "winners_total": $input[19],
              },
              "6": {
                "prize": $input[22],
                "winners_total": $input[21],
              },
              "7": {
                "prize": $input[24],
                "winners_total": $input[23],
              },
              "8": {
                "prize": $input[26],
                "winners_total": $input[25],
              },
              "9": {
                "prize": $input[28],
                "winners_total": $input[27],
              },
            }
          }
        }
    ]
' < tmp/loto_201902.csv > tmp/loto_2.json

echo "️[3/3]"
vim -u NONE +'1d' +'wq!' tmp/loto2017.csv # Remove first line.
jq -Rsn '
    [
      inputs
      | . / "\n"
      | (.[] | select(length > 0) | . / ";") as $input
      | {
          "date": $input[2],
          "first_draw": {
            "draw": $input[4:9],
            "chance": $input[9],
            "results": {
              "1": {
                "prize": $input[12],
                "winners_total": $input[11],
              },
              "2": {
                "prize": $input[14],
                "winners_total": $input[13],
              },
              "3": {
                "prize": $input[16],
                "winners_total": $input[15],
              },
              "4": {
                "prize": $input[18],
                "winners_total": $input[17],
              },
              "5": {
                "prize": $input[20],
                "winners_total": $input[19],
              },
              "6": {
                "prize": $input[22],
                "winners_total": $input[21],
              },
              "7": {
                "prize": $input[24],
                "winners_total": $input[23],
              },
              "8": {
                "prize": $input[26],
                "winners_total": $input[25],
              },
              "9": {
                "prize": $input[28],
                "winners_total": $input[27],
              },
            }
          }
        }
    ]
' < tmp/loto2017.csv > tmp/loto_3.json

# Concat multiple json.
jq -s add tmp/loto_*.json > src/statics/lotoResults.json

echo "️Done!"
