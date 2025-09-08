import { tracked } from "@glimmer/tracking";

export default class DiscourseLotteryV6Lottery {
  @tracked name;
  @tracked draw_at;
  @tracked winner_count;
  @tracked min_participants;
  @tracked status;
  @tracked backup_strategy;
  @tracked specified_winners;
  @tracked participants_count;
  @tracked winners;

  static create(args = {}) {
    return new DiscourseLotteryV6Lottery(args);
  }

  constructor(args = {}) {
    this.id = args.id;
    this.post_id = args.post_id;
    this.name = args.name;
    this.draw_at = args.draw_at;
    this.winner_count = args.winner_count;
    this.min_participants = args.min_participants;
    this.status = args.status;
    this.backup_strategy = args.backup_strategy;
    this.specified_winners = args.specified_winners;
    this.participants_count = args.participants_count || 0;
    this.winners = args.winners || [];
  }

  get isRunning() {
    return this.status === "running";
  }

  get isFinished() {
    return this.status === "finished";
  }

  get isCancelled() {
    return this.status === "cancelled";
  }
}
