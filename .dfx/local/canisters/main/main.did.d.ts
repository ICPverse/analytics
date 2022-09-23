import type { Principal } from '@dfinity/principal';
export interface _SERVICE {
  'correlationVal' : (arg_0: Array<number>, arg_1: Array<number>) => Promise<
      [] | [number]
    >,
  'geometricMeanVal' : (arg_0: Array<number>) => Promise<number>,
  'kNN' : (
      arg_0: Array<[number, number, string]>,
      arg_1: [number, number],
      arg_2: Array<string>,
    ) => Promise<[] | [string]>,
  'linReg' : (arg_0: Array<number>, arg_1: Array<number>) => Promise<
      [] | [[number, number]]
    >,
  'meanVal' : (arg_0: Array<number>) => Promise<[] | [number]>,
  'medianVal' : (arg_0: Array<number>) => Promise<number>,
  'weightedMeanVal' : (
      arg_0: Array<number>,
      arg_1: number,
      arg_2: number,
    ) => Promise<[] | [number]>,
}
