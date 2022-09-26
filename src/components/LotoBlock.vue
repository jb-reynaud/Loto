<template>
  <section class="hero">
    <div class="hero-body">
      <p class="title">Est-ce que tu as gagné au Loto?</p>
      <p class="subtitle">
        Imagine tu joue les mêmes numéros depuis le 4 octobre 2019, soit 902
        tirages (2 par soirée de Loto), il y a t'il une chance que tu aies
        gagné?
      </p>
    </div>
  </section>
  <section class="section">
    <div class="block">
      <h2>Choisis les 5 numéros</h2>
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
      <h2>Choisis le numéro chance</h2>
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
        Lancer le tirage<i class="fas fa-underline"></i>
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
        Tu as dépensé
        <span class="has-text-weight-bold">{{ resultsTotal.outcome }} €</span>
        pour jouer, tu as gagné
        <span class="has-text-weight-bold">{{ resultsTotal.wons }}</span> fois
        pour un montant total de
        <span class="has-text-weight-bold">{{ resultsTotal.income }}</span> €, tu
        as maintenant
        <span class="has-text-weight-bold">{{ resultsTotal.diff }}</span> € ...
        <a @click="reset">Recommencer?</a>
      </div>

      <table class="table">
        <thead>
        <tr>
          <th>Date</th>
          <th>Tirage</th>
          <th>Chance</th>
          <th>Gain</th>
        </tr>
        </thead>
        <tr v-for="result in results" :key="result.annee_numero_de_tirage">
          <td>
            {{ result.date_de_tirage }}
            <span class="tag is-small"
            >{{ result.day_draw === 1 ? "1er" : "2ème" }} tirage</span
            >
          </td>
          <td>
          <span
              v-for="ball in result.balls"
              :key="ball"
              class="tag is-small ball-result-tag"
              :class="{ 'is-success': selectedBalls.includes(ball) }"
          >{{ ball }}</span
          >
          </td>
          <td>
          <span
              v-if="result.chance"
              class="tag is-small ball-result-tag"
              :class="{ 'is-warning': result.chance === selectedChance }"
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
import lotoResults from "./statics/lotoResults.json";

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
      this.selectedChance = this.selectedChance === chance ? null : chance
    },
    draw() {
      this.results = [];
      let firstDrawResult = [];
      let secondDrawResult = [];

      // First draw.
      lotoResults.map((draw) => {
        const balls = [
          draw.boule_1,
          draw.boule_2,
          draw.boule_3,
          draw.boule_4,
          draw.boule_5,
        ];
        const chance = draw.numero_chance;
        firstDrawResult.push({
          ...draw,
          balls,
          chance,
          day_draw: 1,
          level:
            12 -
            2 *
              balls.filter((ball) => this.selectedBalls.includes(ball)).length -
            (chance === this.selectedChance ? 1 : 0),
        });
      });

      firstDrawResult = firstDrawResult
        .filter((draw) => draw.level < 10)
        .map((result) => {
          result.income = this.convertToFloat(
            result["rapport_du_rang".concat(result.level)]
          );
          result.winnersTotal =
            result["nombre_de_gagnant_au_rang".concat(result.level)];
          return result;
        });

      // Second draw.
      lotoResults.map((draw) => {
        const balls = [
          draw.boule_1_second_tirage,
          draw.boule_2_second_tirage,
          draw.boule_3_second_tirage,
          draw.boule_4_second_tirage,
          draw.boule_5_second_tirage,
        ];
        secondDrawResult.push({
          ...draw,
          balls,
          chance: null,
          day_draw: 2,
          level:
            6 -
            balls.filter((ball) => this.selectedBalls.includes(ball)).length,
        });
      });

      secondDrawResult = secondDrawResult
        .filter((draw) => draw.level < 5)
        .map((result) => {
          result.income = this.convertToFloat(
            result["rapport_du_rang".concat(result.level, "_second_tirage")]
          );
          result.winnersTotal =
            result[
              "nombre_de_gagnant_au_rang_".concat(
                result.level,
                "_second_tirage"
              )
            ];
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