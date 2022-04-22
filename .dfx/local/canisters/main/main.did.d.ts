import type { Principal } from '@dfinity/principal';
export interface _SERVICE {
  'geometricMeanVal' : (arg_0: Array<number>) => Promise<number>,
  'meanVal' : (arg_0: Array<number>) => Promise<number>,
  'medianVal' : (arg_0: Array<number>) => Promise<number>,
  'weightedMeanVal' : (
      arg_0: Array<number>,
      arg_1: number,
      arg_2: number,
    ) => Promise<[] | [number]>,
}
