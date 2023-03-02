<template>
  <section class="hero">
    <div class="hero-body">
      <p class="title">Have you won the lottery?</p>
      <p class="subtitle">
        Imagine you play the same numbers since March 6, 2017, that is 1782 draws (2 per Lotto night), is there any chance you could have win?
      </p>
    </div>
  </section>
  <section class="section">
    <div class="block">
      <h2>Choose the 5 numbers</h2>
      <div class="buttons">
        <button
          v-for="i in 49"
          :key="i"
          :disabled="!selectedBalls.includes(i) && selectedBalls.length > 4"
          class="button ball-button"
          :class="{ 'is-success': selectedBalls.includes(i) }"
          @click="selectBall(i)"
        >
          {{ i }}
        </button>
      </div>
    </div>
    <div class="block">
      <h2>Choose the lucky number</h2>
      <div class="buttons">
        <button
          v-for="i in 10"
          :key="i"
          class="button ball-button"
          :class="{ 'is-warning': selectedChance === i }"
          @click="selectChance(i)"
        >
          {{ i }}
        </button>
      </div>
    </div>
    <div v-if="results.length === 0" class="block has-text-centered">
      <button
        :disabled="selectedBalls.length !== 5 || selectedChance === null"
        class="button is-primary"
        @click="draw"
      >
        Start the draw<i class="fas fa-underline"></i>
      </button>
    </div>
    <div v-else class="block has-text-centered">
      <div
        class="notification"
        :class="{
          'is-success': resultsTotal.diff > 0,
          'is-danger': resultsTotal.diff < 0,
        }"
      >
        You spent
        <span class="has-text-weight-bold">{{ resultsTotal.outcome }} €</span>
        to play, you won
        <span class="has-text-weight-bold">{{ resultsTotal.wons }}</span> times
        for a total amount of
        <span class="has-text-weight-bold">{{ resultsTotal.income }}</span> €,
        you've now
        <span class="has-text-weight-bold">{{ resultsTotal.diff }}</span> € ...
        <a @click="reset">Try again?</a>
      </div>

      <table class="table is-striped">
        <thead>
          <tr>
            <th>Date</th>
            <th>Draw</th>
            <th>Chance</th>
            <th>Gain</th>
          </tr>
        </thead>
        <tr v-for="result in results" :key="result.date">
          <td>
            {{ result.date }}
            <span class="tag is-small"
              >{{ result.day_draw === 1 ? "1st" : "2nd" }} draw</span
            >
          </td>
          <td>
            <span
              v-for="ball in result.draw"
              :key="ball"
              class="tag is-small ball-result-tag"
              :class="{ 'is-success': selectedBalls.includes(parseInt(ball)) }"
              >{{ ball }}</span
            >
          </td>
          <td>
            <span
              v-if="result.chance"
              class="tag is-small ball-result-tag"
              :class="{ 'is-warning': parseInt(result.chance) === selectedChance }"
              >{{ result.chance }}</span
            >
          </td>
          <td>{{ result.income }}€</td>
        </tr>
      </table>
    </div>
  </section>
</template>

<script>
import lotoResults from "../statics/lotoResults.json";

export default {
  data() {
    return {
      selectedBalls: [],
      selectedChance: null,
      results: [],
      resultsTotal: { income: 0, wons: 0, total: 0, outcome: 0 },
      withSecondDraw: true,
    };
  },
  watch: {
    selectedBalls(newValue, oldValue) {
      if (newValue.length < 5 && oldValue.length === 5) {
        this.resetResults();
      }
    },
    selectedChance() {
      this.resetResults();
    },
  },
  methods: {
    selectBall(ball) {
      if (this.selectedBalls.includes(ball)) {
        this.selectedBalls = this.selectedBalls.filter((b) => b !== ball);

        return;
      }

      this.selectedBalls.push(ball);
    },
    selectChance(chance) {
      this.selectedChance = this.selectedChance === chance ? null : chance;
    },
    draw() {
      this.results = [];
      let firstDrawResult = [];
      let secondDrawResult = [];

      // First draw.
      lotoResults.map((result) => {
        firstDrawResult.push({
          ...result,
          day_draw: 1,
          level:
            12 -
            2 *
              result.first_draw.draw.filter((ball) =>
                this.selectedBalls.includes(parseInt(ball))
              ).length -
            (parseInt(result.first_draw.chance) === this.selectedChance ? 1 : 0),
        });
      });

      firstDrawResult = firstDrawResult
        .filter((draw) => draw.level < 10)
        .map((result) => {
          result.draw = result.first_draw.draw;
          result.chance = result.first_draw.chance;
          result.income = this.convertToFloat(
            result.first_draw.results[result.level].prize
          );
          result.winnersTotal =
            result.first_draw.results[result.level].winners_total;
          return result;
        });

      // Second draw.
      lotoResults
        .filter((result) => result.second_draw)
        .map((result) => {
          secondDrawResult.push({
            ...result,
            day_draw: 2,
            level:
              6 -
              result.second_draw.draw.filter((ball) =>
                this.selectedBalls.includes(parseInt(ball))
              ).length,
          });
        });

      secondDrawResult = secondDrawResult
        .filter((result) => result.level < 5)
        .map((result) => {
          result.draw = result.second_draw.draw;
          result.chance = result.second_draw.chance;
          result.income = this.convertToFloat(
            result.second_draw.results[result.level].prize
          );
          result.winnersTotal =
            result.second_draw.results[result.level].winners_total;
          return result;
        });

      // Concat.
      this.results = firstDrawResult
        .concat(secondDrawResult)
        .sort((d1, d2) => d2.income - d1.income);
      this.resultsTotal = this.results.reduce(
        (acc, result) => {
          acc.income += Math.round(result.income);
          acc.wons++;
          return acc;
        },
        { income: 0, wons: 0 }
      );
      this.resultsTotal.total = lotoResults.length * 2;
      this.resultsTotal.outcome = lotoResults.length * 3;
      this.resultsTotal.diff =
        this.resultsTotal.income - this.resultsTotal.outcome;
    },
    reset() {
      this.selectedBalls = [];
      this.selectedChance = null;
      this.resetResults();
    },
    resetResults() {
      this.results = [];
      this.resultsTotal = { income: 0, wons: 0, total: 0, outcome: 0 };
    },
    convertToFloat(string) {
      return typeof string === "string"
        ? parseFloat(string.replace(",", "."))
        : string;
    },
  },
};
</script>

<style scoped>
.ball-button {
  width: 40px;
}
.ball-result-tag {
  width: 25px;
}
</style>
