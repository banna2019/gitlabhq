export default class Store {
  constructor({
    titleHtml,
    descriptionHtml,
    descriptionText,
  }) {
    this.state = {
      titleHtml,
      titleText: '',
      descriptionHtml,
      descriptionText,
      taskStatus: '',
      updatedAt: '',
    };
    this.formState = {
      title: '',
      confidential: false,
      description: '',
      lockedWarningVisible: false,
    };
  }

  updateState(data) {
    this.state.titleHtml = data.title;
    this.state.titleText = data.title_text;
    this.state.descriptionHtml = data.description;
    this.state.descriptionText = data.description_text;
    this.state.taskStatus = data.task_status;
    this.state.updatedAt = data.updated_at;
  }

  stateShouldUpdate(data) {
    return {
      title: this.state.titleText !== data.title_text,
      description: this.state.descriptionText !== data.description_text,
    };
  }
}
