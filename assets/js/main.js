const formatNumber = new Intl.NumberFormat("ru-RU", { maximumFractionDigits: 0 });
const calculator = document.querySelector("[data-income-calculator]");

if (calculator) {
  const field = (name) => calculator.elements.namedItem(name);
  const output = (name) => calculator.querySelector(`[data-calc-${name}]`);

  const calculate = () => {
    const hours = Number(field("hours").value);
    const days = Number(field("days").value);
    const rate = Number(calculator.querySelector('input[name="transportRate"]:checked')?.value || 430);
    const city = Number(field("cityFactor").value);
    const demand = Number(field("demandFactor").value);
    const dailyExpenses = Math.max(0, Number(field("expenses").value) || 0);
    const taxRate = Math.max(0, Number(field("tax").value) || 0) / 100;
    const weeks = 4.345;
    const shifts = days * weeks;
    const gross = hours * shifts * rate * city * demand;
    const expenses = dailyExpenses * shifts;
    const tax = gross * taxRate;
    const net = Math.max(0, gross - expenses - tax);
    const shift = shifts > 0 ? net / shifts : 0;
    const low = Math.max(0, net * 0.85);
    const high = net * 1.15;

    calculator.querySelector('[data-calc-output="hours"]').textContent = hours;
    calculator.querySelector('[data-calc-output="days"]').textContent = days;
    output("gross").textContent = formatNumber.format(Math.round(gross / 100) * 100);
    output("expenses").textContent = formatNumber.format(Math.round(expenses / 100) * 100);
    output("tax").textContent = formatNumber.format(Math.round(tax / 100) * 100);
    output("net").textContent = formatNumber.format(Math.round(net / 100) * 100);
    output("shift").textContent = formatNumber.format(Math.round(shift / 50) * 50);
    output("range").textContent = `${formatNumber.format(Math.round(low / 100) * 100)}–${formatNumber.format(Math.round(high / 100) * 100)} ₽`;
  };

  calculator.addEventListener("input", calculate);
  calculator.addEventListener("change", calculate);
  calculate();
}

const header = document.querySelector("[data-header]");

if (header) {
  const updateHeader = () => header.classList.toggle("is-scrolled", window.scrollY > 12);
  window.addEventListener("scroll", updateHeader, { passive: true });
  updateHeader();
}

const metrikaId = Number(document.body.dataset.metrikaId || 0);
const registrationGoal = document.body.dataset.registrationClickGoal || "registration_cta_click";

const reachGoal = (goal, params = {}) => {
  if (metrikaId > 0 && typeof window.ym === "function") {
    window.ym(metrikaId, "reachGoal", goal, params);
  }
};

document.querySelectorAll("[data-cta]").forEach((link) => {
  const placement = link.dataset.cta || "unknown";
  if (link.hasAttribute("data-registration-cta")) {
    const url = new URL(link.href, window.location.origin);
    url.searchParams.set("from", placement);
    link.href = `${url.pathname}${url.search}`;
  }

  link.addEventListener("click", () => {
    reachGoal(link.hasAttribute("data-registration-cta") ? registrationGoal : `${placement}_click`, {
      placement,
      path: window.location.pathname,
    });
  });
});

const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
if (reduceMotion.matches) {
  document.querySelectorAll("video[autoplay]").forEach((video) => video.pause());
}
