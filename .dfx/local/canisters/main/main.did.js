export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'correlationVal' : IDL.Func(
        [IDL.Vec(IDL.Float64), IDL.Vec(IDL.Float64)],
        [IDL.Opt(IDL.Float64)],
        [],
      ),
    'geometricMeanVal' : IDL.Func([IDL.Vec(IDL.Float64)], [IDL.Float64], []),
    'kNN' : IDL.Func(
        [
          IDL.Vec(IDL.Tuple(IDL.Float64, IDL.Float64, IDL.Text)),
          IDL.Tuple(IDL.Float64, IDL.Float64),
          IDL.Vec(IDL.Text),
        ],
        [IDL.Opt(IDL.Text)],
        [],
      ),
    'linReg' : IDL.Func(
        [IDL.Vec(IDL.Float64), IDL.Vec(IDL.Float64)],
        [IDL.Opt(IDL.Tuple(IDL.Float64, IDL.Float64))],
        [],
      ),
    'meanVal' : IDL.Func([IDL.Vec(IDL.Float64)], [IDL.Opt(IDL.Float64)], []),
    'medianVal' : IDL.Func([IDL.Vec(IDL.Float64)], [IDL.Float64], []),
    'weightedMeanVal' : IDL.Func(
        [IDL.Vec(IDL.Float64), IDL.Float64, IDL.Float64],
        [IDL.Opt(IDL.Float64)],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
