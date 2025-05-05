const ExtremeEventSlider = {
  mounted() {
    const slider = this.el;
    const valueElement = document.getElementById("extremeEvent");

    // Update the value display on input
    slider.addEventListener("input", () => {
      if (valueElement) {
        valueElement.innerHTML = slider.value;
      }
    });
  }
};

export default ExtremeEventSlider;
