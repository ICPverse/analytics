import type { Principal } from '@dfinity/principal';
export interface Complex { 'im' : number, 're' : number }
export interface _SERVICE {
  'addComplex' : (arg_0: [number, number], arg_1: [number, number]) => Promise<
      Complex
    >,
  'correlationVal' : (arg_0: Array<number>, arg_1: Array<number>) => Promise<
      [] | [number]
    >,
  'geometricMeanVal' : (arg_0: Array<number>) => Promise<number>,
  'inverse' : (arg_0: [number, number]) => Promise<Complex>,
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
